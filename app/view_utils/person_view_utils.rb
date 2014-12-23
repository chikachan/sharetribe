module PersonViewUtils
  module_function

  # This method is an adapter to `display_name` method.
  # Makes the use easier by allowing Person and Community models as parameters
  def person_display_name(person, community)
    display_name(
      first_name: person.given_name,
      last_name: person.family_name,
      username: person.username,

      name_display_type: community.name_display_type,

      is_organization: person.is_organization,
      organization_name: person.organization_name,

      deleted_user_text: I18n.translate("user_deleted"),
    )
  end

  def display_name(
        first_name:,
        last_name:,
        organization_name:,
        username:,
        name_display_type:,
        is_organization:,
        is_deleted:,
        deleted_user_text:)

    match = ->(expected) {
      ->(actual) {
        actual.zip(expected).all? { |(act, exp)|
          exp.nil? ? true : act === exp
        }
      }
    }

    name_present = first_name.present?
    _ = nil

    case [is_deleted, is_organization, name_present, name_display_type]
    when match.call([true])
      deleted_user_text
    when match.call([_, true])
      organization_name
    when match.call([_, _, true, "first_name_with_initial"])
      first_name_with_initial(first_name, last_name)
    when match.call([_, _, true, "first_name_only"])
      first_name
    when match.call([_, _, true, _])
      full_name(first_name, last_name)
    else
      username
    end
  end

  def full_name(first_name, last_name)
    "#{first_name} #{last_name}"
  end

  def first_name_with_initial(first_name, last_name)
    if last_name.present?
      "#{first_name} #{last_name[0, 1]}"
    else
      first_name
    end
  end
end
