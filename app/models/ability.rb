class Ability < Atmosphere::Ability
  def ability_builder_classes_ext
    [
      ::OwnedPayloadAbilityBuilder
    ]
  end
end