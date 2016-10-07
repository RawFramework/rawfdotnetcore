def view_details_template model
    labels = get_labels model, model.at_xpath("fields").elements
    labels += get_has_many_labels model
    entity_name = model['name']
    name = entity_name
    name_downcase = name.downcase

return <<template
<div id="#{name_downcase}_template">
    #{@use_partial_views ? "" : get_shared_layout(name)}

    <input type="hidden" id="refresh" value="no">

    <h2>Details</h2>
    <div data-bind="foreach: #{model['name']}s" id="details_#{entity_name.downcase}">
        <table class="table table">
            <thead>
                <tr>
                    <th>
                        #{model['name']}
                    </th>
                </tr>
            </thead>
            <tbody>
                #{labels}
            </tbody>
        </table>

        <a data-bind="attr: {href:'/#{model['name']}'}" class="btn btn-primary">Back</a>
        <a data-bind="attr: {href:'/#{model['name']}/Edit/' + #{(entity_name + '.' if @is_view_model)}Id}" class="btn btn-primary">Edit</a>
    </div>

    <script>
        require(["/js/app/#{name}.controller.js", "/js/app/#{name}.binding.js", 'utils'], function (#{name_downcase}Controller, appViewModel, utils) {
            utils.spinner.show();
            var promise = #{name_downcase}Controller.get#{name}("@ViewBag.id");

            promise.done(function (ajaxResult) {
                var model = ajaxResult.#{name_downcase};
                #{format_properties(model)}
                appViewModel.add(model);

                utils.spinner.hide();
            });
        });
    </script>
</div>
template
end

def get_labels entity, elements
    labels = ""
    isVM =elements.xpath("//entity").first['isViewModel'] 
    if isVM == 'True' || isVM == 'true'
        if entity.attribute("objectName")
            entity_name = "#{entity.attribute('objectName')}."
        else
            entity_name = "#{entity.attribute('name')}."
        end
    end

    elements.each do |node|    
        next if node.name.to_s == "Id"
        #Skip hidden fields
        next if node.attribute('validator').to_s["hidden"]

        property_name = node.name

        if node.at_css("HasOne")
            id = node.attribute('HasOne').to_s
            nkg_obj = node.xpath("//entity")
            new_entity = nkg_obj.search("entity[objectName=#{id}]")

            labels += get_labels new_entity, new_entity.at_xpath("fields").elements

        else
            if node.at_css("SelectFrom")
                next
                #id = node.attribute('SelectFrom').to_s
                #nkg_obj = node.xpath("//entity")
                #new_entity = nkg_obj.search("entity[listName=#{id}]")
                #entity_name = "#{new_entity.attribute('listName')}[0]."
                #property_name ="#{node.at_css("SelectFrom").attribute('DisplayField')}"
            end

            labels += "
            <tr>
                <td>#{property_name}:</td>
                <td>
                    <label class='display-label' data-bind='text: #{entity_name}#{property_name}'></label>
                </td>
            </tr>"
        end
        
    end
    labels
end

def get_has_many_labels model
    labels = ""

    has_many_entities = model.xpath("//HasMany/entity")
    has_many_entities.each do |node|
        entityName = node.attribute("name")
        list_name = node.attribute("listName")
        display_name = 
            labels += "
            <tr>
                <td>#{entityName}(s):</td>
                <td>
                    <table class=\"table table-striped\" >
                        <thead>
                            <tr>
                                #{get_columns_names(node)}
                            </tr>
                        </thead>
                        <tbody data-bind=\"foreach: #{list_name}\">
                            <tr>
                                #{get_labels_index node}
                            </tr>
                        </tbody>
                    </table>
                </td>
            </tr>"
    end
    labels
end

def get_shared_layout name
return <<template
@{
        ViewBag.page = "#{entity_name}";
        ViewBag.Title = "#{entity_name} | Details";
        Layout = "~/Views/Shared/_Layout.cshtml";
    }
template
end