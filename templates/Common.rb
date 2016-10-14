def format_properties model, file_type = ""
    result = ""
    property_name = ""
    entity_name = model['name']

    model.search("@validator").each do |node|
        case node.to_s
        when "date"
            property_name = node.parent.name

            case file_type
            when 'index'
                result += "item.#{property_name} = moment(item.#{property_name}).format('l');"
            when 'create_edit'
                result += "model.#{(entity_name + '.' if @is_view_model)}#{property_name} = moment(model.#{(entity_name + '.' if @is_view_model)}#{property_name});"
            else
                result += "model.#{(entity_name + '.' if @is_view_model)}#{property_name} = moment(model.#{(entity_name + '.' if @is_view_model)}#{property_name}).format('l');"
            end
        end 
    end    

    result
end

def get_selectfrom_template model, file_type, field_name, entity_name
    result = ""
    select_name = ""
    property_name = ""
    list_name = ""
    display_field = ""    
    idField = ""
    valueField =""
    found = false
    return result if model.search("SelectFrom").empty?

    model.search("//SelectFrom/entity").each do |node|
        list_name = node.attribute('listName')        

        if list_name.to_s != field_name.to_s
            next
        end
        select_name = node.attribute('name')
                       
        model.search("SelectFrom").each do |node|
            if node.parent.attribute('SelectFrom').to_s == list_name.to_s
                display_field = node.attribute('DisplayField')
                property_name = node.parent.name
                idField = node.attribute('ReferencedField')
                break #we already have it
            end
        end
    end    
    list_name = field_name

    case file_type
    when 'binding_init'
        result = ""
    when 'binding_search'
        model.search("//SelectFrom/entity").each do |node|
            list_name = node.attribute('listName')        
            select_name = node.attribute('name')
                           
            model.search("SelectFrom").each do |node|
                if node.parent.attribute('SelectFrom').to_s == list_name.to_s
                    display_field = node.attribute('DisplayField')
                    property_name = node.parent.name

                    result += ""
                    break #we already have it
                end
            end
        end 
    when 'validate_init'

        model.search("//SelectFrom/entity").each do |node|
            list_name = node.attribute('listName')        
            select_name = node.attribute('name')
                           
            model.search("SelectFrom").each do |node|
                if node.parent.attribute('SelectFrom').to_s == list_name.to_s
                    display_field = node.attribute('DisplayField')
                    property_name = node.parent.name

                    result += ""
                    break #we already have it
                end
            end
        end 
    when 'edit_create'
        #Fix two last parameters, 
        valueField = entity_name + property_name
        result = @form_fields[:select_from] %[select_name, property_name, list_name, display_field, idField, valueField]
    end


    result
end


def get_autocomplete_template model, node, file_type, field_name
    result = ""
    property_name = node.name
    entity_name = model['name']
    searchField = ""
    idField =""
    showField = ""
    order = ""    
    referencedtable =""
    found = false
    #return result if model.Autocomplete.empty?
    #get all the data that we need to set the control
    node.xpath('//Autocomplete').each do |element|
        searchField = element['SearchField']
        idField = element['ReferencedField']
        showField = element['DisplayField']
        order = element['OrderByField']
        referencedtable = element['ReferencedTable']
    end

    case file_type
    when 'binding_init'
        result = ""
    when 'binding_search'
        result = ""
    when 'validate_init'
        result = ""
    when 'edit_create'
        result = @form_fields[:autocomplete] %[property_name, property_name,"data-bind='value: #{entity_name}.#{property_name}'",  "#{property_name}Name", searchField, idField, showField, order, referencedtable]
    end


    result
end

def get_datepicker_template model, file_type
    result = ""
    select_name = ""
    property_name = ""
    list_name = ""
    display_field = ""
    entity_name = model['name']

    return result unless model.search("//@validator='date'")

    model.search("@validator").each do |node|
        case node.to_s
        when "date"
            property_name = node.parent.name
            result += "model.#{(entity_name + '.' if @is_view_model)}#{property_name} = utils.formatDate(model.#{(entity_name + '.' if @is_view_model)}#{property_name});"
        end 
    end       


    case file_type
    when 'validate_init'
        result = "$('##{property_name}').datetimepicker({
            pickTime: false,
            useMinutes: false,               
            useSeconds: false,               
            useCurrent: false
        });"
    when 'validate_change'
        result = "$('##{property_name}')
        .on('dp.change dp.show', function (e) {
            // Revalidate the date when user change it
            $('.user_form').bootstrapValidator('revalidateField', '#{property_name}');
        });"
    
    when 'validate_use'
        if property_name != ""
            result = "viewModel.#{entity_name}s()[0].#{(entity_name + '.') if @is_view_model}#{property_name} = viewModel.dateSelected();"
        end
    when 'edit_create'
        if property_name != ""
            result = @form_fields[:datepicker] %[property_name, property_name, property_name]
        end
    when 'binding_add'
        if property_name != ""
            result = "var date = element.#{entity_name} ? element.#{entity_name}.#{property_name} : element.#{property_name};
                that.dateSelected = ko.observable(date);"
        end
    end


    result
end

def get_has_many_template model, file_type = ""
    result = ""

    case file_type
    when 'edit'
        has_many_entities = model.xpath("//HasMany/entity")
        has_many_entities.each do |node|
            entityName = node.attribute("name")
            list_name = node.attribute("listName")
            display_name = 
                result += "
                <div class='form-group'>
                    <label class='col-sm-2 control-label'>#{entityName}(s)</label>
                    <div class='col-sm-4'>
                        <table class=\"table table-striped\" >
                            <thead>
                                <tr>
                                    #{get_columns_names(node)}
                                </tr>
                            </thead>
                            <tbody data-bind=\"foreach: #{list_name}\">
                                <tr>
                                    #{get_labels_index node}
                                    <td><a data-bind=\"attr: {href: '/#{entityName}/Edit/' + Id}\">Edit</a></td>
                                </tr>
                            </tbody>
                        </table>  
                    </div>
                </div>"
        end
        
    end

    result 
end
@data_types = {}
@data_types["bigint"] = "Int64"
@data_types["binary"] = "Byte[]"
@data_types["bit"] = "Boolean"
@data_types["char"] = "string"
@data_types["date"] = "DateTime"
@data_types["datetime"] = "DateTime"
@data_types["datetime2"] = "DateTime"
@data_types["datetimeoffset"] = "DateTimeOffset"
@data_types["decimal"] = "Decimal"
@data_types["varbinary(max)"] = "Byte[]"
@data_types["float"] = "float"
@data_types["image"] = "Byte[]"
@data_types["int"] = "Int32"
@data_types["money"] = "Decimal"
@data_types["nchar"] = "string"
@data_types["ntext"] = "Guid"
@data_types["numeric"] = "Decimal"
@data_types["nvarchar"] = "string"
@data_types["real"] = "Single"
@data_types["rowversion"] = "Byte[]"
@data_types["smalldatetime"] = "DateTime"
@data_types["smallint"] = "Int16"
@data_types["smallmoney"] = "Decimal"
@data_types["sql_variant"] = "Object"
@data_types["text"] = "string"
@data_types["time"] = "TimeSpan"
@data_types["timestamp"] = "Byte[]"
@data_types["tinyint"] = "Byte"
@data_types["uniqueidentifier"] = "Guid"
@data_types["varbinary"] = "Byte[]"
@data_types["varchar"] = "string"
@data_types["xml"] = "Xml"