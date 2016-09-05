def view_index_template model, use_bs_grid = false
    name = model['name']
    name_downcase = name.downcase

    grid_file = ", '/wwwroot/js/app/#{name}.grid.js'"
    grid_container = "<div id='bs_grid_#{name_downcase}'></div>"

return <<template
<div id="#{name_downcase}_template">
    #{@use_partial_views ? "" : get_shared_layout(name)}

    <input type="hidden" id="refresh" value="no">

    <h2>#{name}</h2>
    <div id="index_#{name.downcase}">
    #{(use_bs_grid ? grid_container: get_table(model))}
    </div>
    <a href="/#{name}/Create" class="btn btn-primary">Add</a>
        
    <script>
        require(["/wwwroot/js/app/#{name}.controller.js", "/wwwroot/js/app/#{name}.binding.js", 'moment', 'utils', 'underscore' #{grid_file if use_bs_grid}], function (#{name_downcase}Controller, appViewModel, moment, utils, _) {
            utils.spinner.show();
            var promise = #{name_downcase}Controller.get#{name}s();

            promise.done(function (ajaxResult) {
                _.each(ajaxResult.#{name_downcase}s, function (item) {
                    var model = ajaxResult.#{name_downcase}s;
                    #{format_properties(model, 'index')}
                    appViewModel.add(item);
                });

                utils.spinner.hide();
            });
        });
    </script>
</div>
template
end

def get_labels_index model
    labels = ""
    elements = model.at_xpath("fields").elements


    elements.each do |node|    
        name = node.name.to_s
        next if (node.name.to_s == "Id" || node.has_attribute?("SelectFrom") || 
            node.has_attribute?("HasOne")) || node.xpath("@validator='date'") ||
            (name[(name.length() -2)...name.length] == "Id" || node.attribute('validator').to_s["hidden"])

        property_name = node.name
        labels += "
            <td>
                <label class='display-label' data-bind='text: #{property_name}'></label>
            </td>"
    end
    labels
end

def get_columns_names model
    labels = ""
    elements = model.at_xpath("fields").elements


    elements.each do |node|    
        name = node.name.to_s
        next if (node.name.to_s == "Id" || node.has_attribute?("SelectFrom") || 
            node.has_attribute?("HasOne")) || node.xpath("@validator='date'") ||
            (name[(name.length() -2)...name.length] == "Id" || node.attribute('validator').to_s["hidden"])

        property_name = node.name
        labels += "
            <th>
                #{property_name}
            </th>"
    end
    labels
end

def get_table model
    name = model['name']
return <<template
    <table class="table table-striped" >
        <thead>
            <tr>
                #{get_columns_names(model)}
            </tr>
        </thead>
        <tbody data-bind="foreach: #{name}s">
            <tr>
                #{get_labels_index model}
                <td><a data-bind="attr: {href: '/#{name}/Details/' + Id}">Details</a></td>
                <td><a data-bind="attr: {href: '/#{name}/Edit/' + Id}">Edit</a></td>
                <td><a data-bind="click: $parent.remove">Remove</a></td>
            </tr>
        </tbody>
    </table>
template
end

def get_shared_layout name
return <<template
@{
        ViewBag.page = "#{name}";
        ViewBag.Title = "#{name} | List";
        Layout = "~/Views/Shared/_Layout.cshtml";   
    }
template
end