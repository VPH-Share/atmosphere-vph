Atmosphere.setup do |config|
  config.delegation_initconf_key = Air.config.mi_authentication_key

  config.admin_entites_ext = {
    main_app: [ SecurityProxy, SecurityPolicy ]
  }

  config.redis_url = Air.config.sidekiq.url
  config.redis_namespace = Air.config.sidekiq.namespace
end