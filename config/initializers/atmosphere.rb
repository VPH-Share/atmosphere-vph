require 'atmosphere/cached_delegator'

Atmosphere.setup do |config|
  config.delegation_initconf_key = Settings.mi_authentication_key

  config.admin_entites_ext = {
    main_app: [ SecurityProxy, SecurityPolicy ]
  }

  if Settings['sidekiq']
    config.sidekiq.url = Settings.sidekiq.url
    config.sidekiq.namespace = Settings.sidekiq.namespace
  end

  if Settings['at_pdp']
    config.at_pdp_class = Settings.at_pdp.constantize
  end

  if Settings['zabbix']
    config.monitoring_client = Atmosphere::Monitoring::ZabbixClient.new
  end

  if Settings['influxdb']
    config.metrics_store = Atmosphere::CachedDelegator.new(60.minutes) do
      Atmosphere::Monitoring::InfluxdbMetricsStore.new(Settings['influxdb'])
    end
  end
end