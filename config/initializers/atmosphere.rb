require 'atmosphere/cached_delegator'

Atmosphere.setup do |config|
  config.delegation_initconf_key = Settings.mi_authentication_key

  config.admin_entites_ext = {
    main_app: [ SecurityProxy, SecurityPolicy ]
  }

  config.ability_class = 'Ability'

  if Settings['at_pdp']
    config.at_pdp_class = Settings.at_pdp.constantize
  end
end
