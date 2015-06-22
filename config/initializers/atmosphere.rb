require 'atmosphere/cached_delegator'

Atmosphere.setup do |config|
  config.delegation_initconf_key = Settings.mi_authentication_key

  config.admin_entites_ext = {
    main_app: [ SecurityProxy, SecurityPolicy ]
  }

  config.ability_class = 'Ability'

  if Settings['azure_vm_password']
    config.azure_vm_password = Settings.azure_vm_password
  end

  if Settings['azure_vm_user']
    config.azure_vm_user = Settings.azure_vm_user
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