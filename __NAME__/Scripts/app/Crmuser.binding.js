define(['jquery', 'knockout', 'underscore', 'moment'], function ($, ko, _, moment) {
    if ($("#refresh").val() == 'yes') { location.reload(); } else { $('#refresh').val('yes'); }
        
    var modelCrmuser = [
    ];

    ko.bindingHandlers.datetimepicker = {
        init: function (element, valueAccessor, allBindingsAccessor) {

            var options = {
                pickTime: false,
                defaultDate: AppViewModel.dateSelected()
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

    var AppViewModel = {
        Crmusers: ko.observableArray(
            modelCrmuser
        ),

        add : function (element) {
            var that = this;
            $.extend(element, { ConfirmPassword: '' });
            that.Crmusers.push(element);
        },

        remove: function () {
            var self = this;
            $.post("/Crmuser/Delete", { id: this.Id }, function (success) {
                if (Boolean(success)) {
                    AppViewModel.Crmusers.remove(self);
                }
            });
        },

        dateSelected: ko.observable()


    };

    $(document).ready(function () {
        ko.applyBindings(AppViewModel);
    });
    return AppViewModel;

});
