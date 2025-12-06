module RecipientsHelper
    def display_age(recipient)
        if recipient.age.present?
            recipient.age
        elsif recipient.min_age.present? && recipient.max_age.present?
            "#{recipient.min_age}–#{recipient.max_age}"
        elsif recipient.min_age.present? && !recipient.max_age.present?
            recipient.min_age
        else
            "No Age Selected"
        end
    end
end
