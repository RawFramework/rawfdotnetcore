define(['jquery', 'bootstrapValidator', 'moment', 'bootstrapDateTimePicker'], function ($) {
    var initValidator = function () {
        

        $(".account_form").bootstrapValidator({
            // To use feedback icons, ensure that you use Bootstrap v3.1.0 or later
            feedbackIcons: {
                valid: 'glyphicon glyphicon-ok',
                invalid: 'glyphicon glyphicon-remove',
                validating: 'glyphicon glyphicon-refresh'
            },
            fields: {
                
                Id: {
                     message: 'The Id is not valid',
                     validators: {
                        notEmpty: {
                            
                          }
                     }
                   },

                OwnerId: {
                     message: 'The OwnerId is not valid',
                     validators: {
                        
                     }
                   },

                AccountName: {
                     message: 'The AccountName is not valid',
                     validators: {
                        notEmpty: {
                            max: 50
                          },
                            max: {
                            
                          }
                     }
                   },

                ParentAccountId: {
                     message: 'The ParentAccountId is not valid',
                     validators: {
                        
                     }
                   },

                AccountNumber: {
                     message: 'The AccountNumber is not valid',
                     validators: {
                        max: {
                            max: 50
                          }
                     }
                   },

                AccountTypeId: {
                     message: 'The AccountTypeId is not valid',
                     validators: {
                        
                     }
                   },

                IndustryId: {
                     message: 'The IndustryId is not valid',
                     validators: {
                        
                     }
                   },

                Phone: {
                     message: 'The Phone is not valid',
                     validators: {
                        phone: {
                            country:'US'
                          }
                     }
                   },

                Fax: {
                     message: 'The Fax is not valid',
                     validators: {
                        phone: {
                            country: 'US'
                          }
                     }
                   },

                Website: {
                     message: 'The Website is not valid',
                     validators: {
                        max: {
                            max: 50
                          }
                     }
                   },

                Employees: {
                     message: 'The Employees is not valid',
                     validators: {
                        
                     }
                   },

                Description: {
                     message: 'The Description is not valid',
                     validators: {
                        max: {
                            max: 2147483647
                          }
                     }
                   },

                IsLead: {
                     message: 'The IsLead is not valid',
                     validators: {
                        
                     }
                   },

                LeadStatusId: {
                     message: 'The LeadStatusId is not valid',
                     validators: {
                        
                     }
                   },

                LeadSourceId: {
                     message: 'The LeadSourceId is not valid',
                     validators: {
                        
                     }
                   },

                LeadRatingId: {
                     message: 'The LeadRatingId is not valid',
                     validators: {
                        
                     }
                },
                Street: {
                    message: 'The Street is not valid',
                    validators: {
                        max: {
                            max: 50
                        },
                        notEmpty: {

                        }
                    }
                }, City: {
                    message: 'The City is not valid',
                    validators: {
                        notEmpty: {
                            max: 50
                        },
                        max: {

                        }
                    }
                },

                ZipCode: {
                    message: 'The ZipCode is not valid',
                    validators: {
                        notEmpty: {
                            max: 20
                        },
                        max: {

                        }
                    }
                },

                Country: {
                    message: 'The Country is not valid',
                    validators: {
                        max: {
                            max: 50
                        },
                        notEmpty: {

                        }
                    }
                }
            }
        }).on('success.form.bv', function (e) {
            e.preventDefault();

            var $form = $(e.target);

            viewModel.Accounts()[0].Account.IndustryId = viewModel.selectedIndustry ? viewModel.selectedIndustry.Id : '';
            viewModel.Accounts()[0].Account.AccountTypeId = viewModel.selectedAccountType ? viewModel.selectedAccountType.Id : '';
            viewModel.Accounts()[0].Account.LeadSourceId = viewModel.selectedLeadSource ? viewModel.selectedLeadSource.Id : '';
            viewModel.Accounts()[0].Account.LeadStatusId = viewModel.selectedLeadStatus ? viewModel.selectedLeadStatus.Id : '';
            viewModel.Accounts()[0].Account.LeadRatingId = viewModel.selectedLeadRating ? viewModel.selectedLeadRating.Id : '';
            viewModel.Accounts()[0].Account.ParentAccountId = viewModel.selectedAccount ? viewModel.selectedAccount.Id : '';

            

            var jsonObj = {
                model: viewModel.Accounts()[0]
            };
            
            $.ajax({
                type: "POST",
                url: $form.attr('action'),
                dataType: "json",
                data: JSON.stringify(jsonObj),
                contentType: "application/json; charset=utf-8",
                success: function (response) {
                  window.history.back();
                }
            });
        });
    };

    var initViewModel = function (model) {
        viewModel = model;
    };

    
    
    var formValidator = {        
        initViewModel: initViewModel,
        initValidator: initValidator
    };
    

    return formValidator;
});
