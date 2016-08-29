define(['jquery', 'utils'], function ($, utils) {
    var ajaxCalls = {};
    var baseUrl = "/Account", //This is the controller on MVC%
        getAccountsUrl = baseUrl + "/GetAccounts", //this is the method on the MVC5 controller
        getAccountUrl = baseUrl + "/GetAccount";
    
    function getAccounts(isLead) {
        var data = {
            isLead: isLead === "" ? false : isLead
        };
        return utils.makeAjaxCall(getAccountsUrl, data);
    }
    
    function getAccount(id, isLead) {
        var data = {
            id: id,
            isLead: isLead === ""?false:isLead
        };
        
        return utils.makeAjaxCall(getAccountUrl, data);
    }
    
    ajaxCalls = {
        getAccounts: getAccounts,
        getAccount: getAccount
    };


    return ajaxCalls;
});
