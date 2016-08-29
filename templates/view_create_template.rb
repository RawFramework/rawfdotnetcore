def view_create_template model
fields = get_fields model
entity_name = model['name']
name = entity_name
name_downcase = name.downcase

return <<template
<div id="#{name_downcase}_template">
    #{@use_partial_views ? "" : get_shared_layout(name)}

    <div class="page-header text-center">
        <h2>Create</h2>
    </div>
    <form id="create_#{entity_name.downcase}_form" method="post" class="form-horizontal #{model['name'].downcase}_form" action="create" role="form" data-bind="foreach: #{entity_name}s">
        #{fields}
        <div class="form-group">
            <div class="col-sm-offset-2 col-sm-10">
                <!-- Do NOT use name="submit" or id="submit" for the Submit button -->
                <button type="submit" class="btn btn-primary">Create</button>

            </div>
        </div>
    </form>
    <script>
        require(["/Scripts/app/#{name}.controller.js", "/Scripts/app/#{name}.binding.js", "/Scripts/app/#{name}.validate.js", 'utils','typeahead'], function (#{name_downcase}Controller, appViewModel, formValidator, utils, type) {
            utils.spinner.show();
            var promise = #{name_downcase}Controller.get#{name}("00000000-0000-0000-0000-000000000000");
            promise.done(function (ajaxResult) {
                var model = ajaxResult.#{name_downcase};
                #{format_properties(model, 'create_edit')}
                appViewModel.add(model);
                //set the root element
                appViewModel.rootElement='create_#{entity_name.downcase}_form';
                formValidator.initViewModel(appViewModel);
                formValidator.initValidator();
                //The typeahead 
                $.each($('.autocomplete'),function (index,element) {
                    $(element).typeahead({
                        onSelect: function (item) {
                            if (item.value == '00000000-0000-0000-0000-000000000000')
                                setTimeout(function () { $(element).val(''); }, 100);
                            //the sibling holds the id
                            $(element).parent().children(':hidden:first').val(item.value).change();
                        },
                        ajax: {
                            url:  '/' + $(element).attr('referencedtable') + '/search?searchField=' + $(element).attr('searchfield') + '&idField=' + $(element).attr('idfield') + '&showField=' + $(element).attr('showfield') + '&order=' + $(element).attr('order'),
                            triggerLength: 2
                        }
                    });
                });

                utils.spinner.hide();
            });

            
        });
    </script>
</div>
template
end

def get_fields model
    elements = model.at_xpath("fields").elements
    fields = ""
    entity_name = ""

    if elements.xpath("//entity").length > 1
        entity_name = elements.xpath("//entity").first['name'] + "."
    end

    elements.each do |node|    
        property_name = node.name
        next if property_name.to_s == "Id"
        #Skip hidden fields
        next if node.attribute('validator').to_s["hidden"]

        if node.at_css("SelectFrom")
            fields += get_selectfrom_template model, 'edit_create', node.attribute('SelectFrom')
        elsif node.at_css("Autocomplete")
            fields += get_autocomplete_template model, node, 'edit_create' , node.attribute('Autocomplete')
        elsif node.at_css("HasOne")
            next
        elsif node.attribute('validator').to_s["bool"]
                fields += @form_fields[:checkbox] %[property_name, property_name, "data-bind='checked: #{entity_name}#{property_name}'"]
        elsif node.attribute('validator').to_s == "date"
            fields += get_datepicker_template(model, 'edit_create')
        else
            fields += @form_fields[:text] %[property_name, property_name, "data-bind='value: #{entity_name}#{property_name}'" ]
        end
        
    end
    fields

end

def get_shared_layout name
return <<template
@{
        ViewBag.page = "#{entity_name}";
        ViewBag.Title = "#{entity_name} | Create";
        Layout = "~/Views/Shared/_Layout.cshtml";
    }
template
end