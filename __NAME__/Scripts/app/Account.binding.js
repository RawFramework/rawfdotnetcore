define(['jquery', 'knockout', 'underscore', 'moment'], function ($, ko, _, moment) {
    if ($("#refresh").val() == 'yes') { location.reload(); } else { $('#refresh').val('yes'); }
        
    var modelAccount = [
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
        Accounts: ko.observableArray(
            modelAccount
        ),

        add : function (element) {
            var that = this;

            that.selectedIndustry = {};
                            _.each(element.Industries, function (item) {
                                if (item.Id === element.Account.IndustryId) {
                                    that.selectedIndustry = item;
                                }
                            });
            that.selectedAccountType = {};
                            _.each(element.AccountTypes, function (item) {
                                if (item.Id === element.Account.AccountTypeId) {
                                    that.selectedAccountType = item;
                                }
                            });
            that.selectedLeadSource = {};
                            _.each(element.LeadSources, function (item) {
                                if (item.Id === element.Account.LeadSourceId) {
                                    that.selectedLeadSource = item;
                                }
                            });
            that.selectedLeadStatus = {};
                            _.each(element.LeadStatuses, function (item) {
                                if (item.Id === element.Account.LeadStatusId) {
                                    that.selectedLeadStatus = item;
                                }
                            });
            that.selectedLeadRating = {};
                            _.each(element.LeadRatings, function (item) {
                                if (item.Id === element.Account.LeadRatingId) {
                                    that.selectedLeadRating = item;
                                }
                            });

            that.selectedAccount = {};
                        _.each(element.Accounts, function(item) {
                            if (element.ParentAccount && item.Id === element.ParentAccount.ParentAccountId) {
                                that.selectedAccount = item;
                            }
                        });

            that.Accounts.push(element);
        },
        removeForRebind: function () {
            var self = this;
            self.Accounts.pop();
        },
        remove: function () {
            var self = this;
            $.post("/Account/Delete", { id: this.Id }, function (success) {
                if (Boolean(success)) {
                    AppViewModel.Accounts.remove(self);
                }
            });
        },
        getPriority: function (p) {
            switch (p) {
                case 0:
                    return "Lowest";
                    break;
                case 1:
                    return "Low";
                    break;
                case 2:
                    return "Normal";
                    break;
                case 3:
                    return "High";
                    break;
                case 4:
                    return "Highest";
                    break;
            }
        },
        communicationTypes: ko.observableArray(),
        getCommunicationType: function (id) {
            var self = this;
            for (x in self.communicationTypes()) {
                if (self.communicationTypes()[x].Id == id) {
                    return self.communicationTypes()[x].CommunitacionTypeName;
                }
            }
            return "Unknown";
        },
        getCommunicationTypeForEdit: function (id) {
            var self = this;
            for (x in self.communicationTypes()) {
                if (self.communicationTypes()[x].Id == id) {
                    return self.communicationTypes()[x].CommunitacionTypeName;
                }
            }
            return "Unknown";
        },
        dateSelected: ko.observable(),
        selected: ko.observable()


    };

    $(document).ready(function () {
        ko.applyBindings(AppViewModel, document.getElementById("accountList"));
    });
    return AppViewModel;

});
