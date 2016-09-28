def js_binding_template model
    name = model['name']
    name_downcase = name.downcase

return <<template
define(['jquery', 'knockout', 'underscore', 'moment'], function ($, ko, _, moment) {
    if ($("#refresh").val() == 'yes') { location.reload(); } else { $('#refresh').val('yes'); }
        
    var model#{name} = [
    ];

    ko.bindingHandlers.datetimepicker = {
        init: function (element, valueAccessor, allBindingsAccessor) {

            var options = {
                pickTime: false,
                defaultDate: #{name}AppViewModel.dateSelected()
            };

            $(element).parent().datetimepicker(options);

            ko.utils.registerEventHandler($(element).parent(), "change.dp", function (event) {
                var value = valueAccessor();
                if (ko.isObservable(value)) {
                    var thedate = $(element).parent().data("DateTimePicker").getDate();
                    value(moment(thedate).toDate());
                }
            });
        },
        update: function (element, valueAccessor) {
            var widget = $(element).parent().data("DateTimePicker");
            //when the view model is updated, update the widget
            var thedate = new Date(parseInt(ko.utils.unwrapObservable(valueAccessor()).toString().substr(6)));
            widget.setDate(thedate);
        }
    };

    var #{name}AppViewModel = {
        #{name}s: ko.observableArray(
            model#{name}
        ),

        add : function (element) {
            var that = this;

            #{get_selectfrom_template(model, 'binding_search', '')}
            #{get_datepicker_template(model, 'binding_add')}
            that.#{name}s.push(element);
        },

        remove: function () {
            var self = this;
            $.post("/#{name}/Delete", { id: this.Id }, function (success) {
                if (Boolean(success)) {
                    #{name}AppViewModel.#{name}s.remove(self);
                }
            });
        },

        rootElement: "#{@use_partial_views ? name_downcase+"_template" : ""}",

        dateSelected: ko.observable()#{get_selectfrom_template(model, 'binding_init', '')}


    };

    $(document).ready(function () {
        //if a root element is defined, then use it
        if(#{name}AppViewModel.rootElement)
            ko.applyBindings(#{name}AppViewModel ); 
        else
            ko.applyBindings(#{name}AppViewModel,document.getElementById(#{name}AppViewModel.rootElement)); 
    });
    return #{name}AppViewModel;

});
template
end