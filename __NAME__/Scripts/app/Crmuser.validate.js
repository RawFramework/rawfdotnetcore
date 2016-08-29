define(['jquery', 'bootstrapValidator', 'moment', 'bootstrapDateTimePicker'], function ($) {
    var initValidator = function () {
        

        $(".crmuser_form").bootstrapValidator({
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

                UserName: {
                    message: 'The UserName is not valid',
                    threshold: 4,
                     validators: {
                        notEmpty: {
                            max: 50
                          },
                        max: {
                            
                        },
                        remote: {
                            message: 'The username is not available',
                            url: '/SignOn/UsernameIsAvailable/',
                            type: 'POST'
                        }
                     }
                   },

                Password: {
                     message: 'The Password is not valid',
                     validators: {
                        max: {
                            max: 50
                          },
                        notEmpty: {
                            
                        },
                        identical: {
                            field: 'ConfirmPassword',
                            message: 'The password and its confirm are not the same'
                        }
                     }
                },
                ConfirmPassword: {
                    message: 'The Confirm Password is not valid',
                    validators: {
                        notEmpty: {
                            max: 50
                        },
                        max: {
                        },
                        identical: {
                            field: 'Password',
                            message: 'The password and its confirm are not the same'
                        }
                    }
                },

                Name: {
                     message: 'The Name is not valid',
                     validators: {

                        notEmpty: {
                            max: 50
                          },
                            max: {
                            
                          }
                     }
                   },

                Email: {
                    message: 'The Email is not valid',
                    verbose: false,
                     validators: {
                        notEmpty: {
                            max: 150
                          },
                            max: {
                            
                          },
                            emailAddress: {
                            
                        },
                        remote: {
                            message: 'The email is not available',
                            url: '/SignOn/EmailIsAvailable/',
                            type: 'POST'
                        }
                     }
                   },
            }
        }).on('success.form.bv', function (e) {
            e.preventDefault();
            var $form = $(e.target);
            var jsonObj = {
                model: viewModel.Crmusers()[0]
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
