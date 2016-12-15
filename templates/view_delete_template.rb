def view_delete_template name
    name_downcase = name.downcase
return <<template
<div id="#{name_downcase}_template" class="hidden">
    #{@use_partial_views ? "" : get_shared_layout(name)}

    <h2>Delete</h2>

    <h3>Are you sure you want to delete this?</h3>
    <fieldset>
        <legend>User</legend>

        <div class="display-label">
             @Html.DisplayNameFor(model => model.Name)
        </div>
        <div class="display-field">
            @Html.DisplayFor(model => model.Name)
        </div>

        <div class="display-label">
             @Html.DisplayNameFor(model => model.Email)
        </div>
        <div class="display-field">
            @Html.DisplayFor(model => model.Email)
        </div>

        <div class="display-label">
             @Html.DisplayNameFor(model => model.City)
        </div>
        <div class="display-field">
            @Html.DisplayFor(model => model.City)
        </div>
    </fieldset>
    @using (Html.BeginForm()) {
        @Html.AntiForgeryToken()
        <p>
            <input type="submit" value="Delete" /> |
            @Html.ActionLink("Back to List", "Index")
        </p>
    }
</div>
template
end

def get_shared_layout name
return <<template
@{
        ViewBag.page = "#{name}";
        ViewBag.Title = "#{name} | Delete";
        Layout = "~/Views/Shared/_Layout.cshtml";
    }
template
end