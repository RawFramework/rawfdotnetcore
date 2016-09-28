def model_template model
fields = get_fields_for_model model.at_xpath("fields").elements

return <<template
using System;
using System.Collections.Generic;
using System.Linq;
using Needletail.DataAccess.Attributes;
using DataAccess.Scaffold.Attributes;

namespace #{@solution_name_sans_extension}.Models
{
    public class #{model["name"]}
    {
        #{fields}
    }
}
template
end

def get_fields_for_model elements
    fields = ""

    elements.each do |node|    
        params = ""

        type = get_data_type node

        attrParams = node.at_css("Validator") ? node.at_css("Validator").attribute_nodes : []


        if attrParams.length > 0
            attrParams.each do |attrb|
                params += "#{attrb.to_s}, "
            end
            params = "(#{params.chomp(', ')})"
        end

        attributes = get_attributes node


        if node.name == "Id"
            attributes += "[TableKey(CanInsertKey = true)]"
        end

        fields += "
        #{attributes}
        public #{type} #{node.name} { get; set; }
        "
    end
    fields
end

def get_attributes property
    result = ""

    if property.has_attribute?('validator')
        attributes = property.attribute('validator').to_s().split(' ')
        attributes.map! { |attribute| 
            param = property.search("@#{attribute.capitalize}")

            param = param.empty? ? "" : "(#{param})"

            attribute = @dictionary_validators[attribute] || next
            

            result += "[#{attribute}#{param}]"
        }
    end

    result
end

def get_data_type property
    type = @data_types[property.attribute("dataType").to_s]
    name = property.name.to_s

    if property.has_attribute?('validator')
        is_required = false
        attributes = property.attribute('validator').to_s().split(' ')

        attributes.map! { |attribute| 
            is_required = attribute == "notEmpty" || is_required
            attribute = @dictionary_data_types[attribute] || next
            type = attribute
        }

        type += "?" if !is_required && type != "string"

    end

    type
end