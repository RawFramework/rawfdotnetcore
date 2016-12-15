def view_edit_template model
fields = get_fields_edit model
entity_name = model['name']
name = entity_name
name_downcase = name.downcase

return <<template
<div id="#{name_downcase}_template" class="hidden">
    #{@use_partial_views ? "" : get_shared_layout(name)}

    <div class="page-header text-center">
        <h2>Edit</h2>
    </div>
    <form id="edit_#{name_downcase}_form" method="post" class="form-horizontal #{name_downcase}_form" action="Edit" role="form" data-bind="foreach: #{model['name']}s">
        #{fields}

        <div class="form-group">
            <div class="col-sm-offset-2 col-sm-10">
                <!-- Do NOT use name="submit" or id="submit" for the Submit button -->
                <button type="submit" class="btn btn-primary">Save</button>
                <button type="button" class="btn btn-danger" onclick="window.history.go(-1)">Cancel</button>
            </div>
        </div>
    </form>

    <script>
        require(["/js/app/#{name}.controller.js", "/js/app/#{name}.binding.js", "/js/app/#{name}.validate.js", 'utils','typeahead'], function (#{name_downcase}Controller, appViewModel, formValidator, utils,type) {
            utils.spinner.show();
            var promise = #{name_downcase}Controller.get#{name}("@ViewBag.id");
            promise.done(function (ajaxResult) {
                var model = ajaxResult.#{name_downcase};
                #{format_properties(model, 'create_edit')}  
                appViewModel.add(model);
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
                //fill the autocomplete text boxes
                $.each($('.autocomplete'),function (index,element) {
                    //launch a search for each hidden
                    $.get(
                        '/' + $(element).attr('referencedtable') + '/GetTextForAutocomplete?id=' + $(element).parent().children(':hidden:first').val() + '&idField=' + $(element).attr('idfield') + '&showField=' + $(element).attr('showfield'),
                        {},
                        function (data){
                            $(element).val(data.name);
                        });
                    
                });
                $("##{name_downcase}_template").removeClass('hidden');
                utils.spinner.hide();
            });
        });
    </script>
</div>
template
end

def get_fields_edit model
    elements = model.at_xpath("fields").elements
    fields = ""
    entity_name = ""
    #if is a viewmodel
    #if elements.xpath("//entity").length > 1
    isVM =elements.xpath("//entity").first['isViewModel'] 
    if isVM == 'True' || isVM == 'true'
        entity_name = elements.xpath("//entity").first['name'] + "."
    end

    elements.each do |node|    
        property_name = node.name

        #do not show hidden fields
        if node.attribute('validator').to_s["hidden"]
            fields += @form_fields[:hidden] %[property_name, "data-bind='value: #{entity_name}#{property_name}'"]
        elsif property_name.to_s == "Id"
            fields += @form_fields[:hidden] %[property_name, "data-bind='value: #{entity_name}#{property_name}'"]
        elsif node.attribute('validator').to_s["bool"]
                fields += @form_fields[:checkbox] %[property_name, property_name, "data-bind='checked: #{entity_name}#{property_name}'"]
        elsif node.at_css("SelectFrom")
            fields += get_selectfrom_template model, 'edit_create', node.attribute('SelectFrom'), entity_name
        elsif node.at_css("Autocomplete")
            fields += get_autocomplete_template model, node, 'edit_create' , node.attribute('Autocomplete')
        elsif node.at_css("HasOne")
            reference = node.attribute('HasOne')
            nkg_obj = node.xpath("//entity")
            has_one = nkg_obj.search("entity[objectName=#{reference}]")
            has_one_name = has_one.attribute('name')

            fields += @form_fields[:button] %[has_one_name, "data-bind=\"attr:{href: '/#{has_one_name}/edit/' + #{entity_name}#{property_name}}\"", property_name]
        elsif node.attribute('validator').to_s == "date"
            fields += get_datepicker_template(model, 'edit_create')
        else
            fields += @form_fields[:text] %[property_name, property_name, "data-bind='value: #{entity_name}#{property_name}'"]
        end
        
    end

    fields += get_has_many_template(model, 'edit')
    fields

end

def get_shared_layout name
return <<template
@{
        ViewBag.page = "#{entity_name}";
        ViewBag.Title = "#{entity_name} | Edit";
        Layout = "~/Views/Shared/_Layout.cshtml";
    }
template
end