require 'atmosphere/cached_delegator'

Atmosphere.setup do |config|
  config.delegation_initconf_key = Air.config.mi_authentication_key

  config.admin_entites_ext = {
    main_app: [ SecurityProxy, SecurityPolicy ]
  }

  config.sidekiq.url = Air.config.sidekiq.url
  config.sidekiq.namespace = Air.config.sidekiq.namespace

  if Air.config['at_pdp']
    config.at_pdp_class = Air.config.at_pdp.constantize
  end

  if Air.config['zabbix']
    config.monitoring_client = Atmosphere::Monitoring::ZabbixClient.new
  end

  if Air.config['influxdb']
    config.metrics_store = Atmosphere::CachedDelegator.new(60.minutes) do
      Atmosphere::Monitoring::InfluxdbMetricsStore.new(config['influxdb'])
    end
  end
end