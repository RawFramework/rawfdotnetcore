def controller_template model, keytype, entityNameSpace, root_namespace
    name = model['name']
    name_downcase = name.downcase
    viewModelSufix = ""    
    useRepositories = true

    isVM =model.xpath("//entity").first['isViewModel'] 
    if isVM == 'True' || isVM == 'true'
        @is_view_model = true
        viewModelSufix = "ViewModel"    
        useRepositories = false
    end
    
return <<template
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using System.Reflection;
using #{@solution_name_sans_extension}.Repositories;
using #{entityNameSpace};
#{root_namespace}


namespace #{@solution_name_sans_extension}.Controllers
{

    //Basic Controller template, avoid adding bussiness logic code here, use the Repository instead
    public class #{name}Controller : Controller
    {
        public Dictionary<string, Func<#{name}, IComparable>> DynamicOrdering = new Dictionary<string, Func<#{name}, IComparable>>
        {#{get_properties(model, 'dictionary')}
        };

        #{get_repositories(model, 'declaration')}

        public #{name}Controller() {

            //Remove this line if you want to use dependency injection 
            #{get_repositories(model, 'init')}
        }

        //
        // GET: /#{name}/

        public ActionResult Index()
        {
            return View();
        }

        //
        // GET: /#{name}/Details/id

        public ActionResult Details(#{keytype} id)
        {
            ViewBag.id = id;
            return View();
        }

        //
        // GET: /#{name}/Create

        public ActionResult Create()
        {
            return View();
        }

        //
        // POST: /#{name}/Create

        [HttpPost]
        public async Task<ActionResult> Create([FromBody]#{name}#{viewModelSufix} model)
        {

            #{(useRepositories ? "model.Id = Guid.NewGuid();" +
            "await #{name_downcase}Repository.InsertAsync(model);" : 
            "model.#{name}.Id = Guid.NewGuid();
            #{get_has_ones(model)}
             await model.SaveAsync();")}

            return Json(new { result = "Redirect", url = Url.Action("Index", "#{name}") });
        }

        //
        // GET: /#{name}/Edit/id

        public ActionResult Edit(#{keytype} id)
        {
            ViewBag.id = id;
            return View();
        }

        //
        // POST: /#{name}/Edit/id

        [HttpPost]
        public async Task<ActionResult> Edit([FromBody]#{name}#{viewModelSufix} model)
        {
            #{(useRepositories ? 
            "var result = await #{name_downcase}Repository.UpdateWithWhereAsync(values: model,
                            where: new {Id = model.Id});" : 
            "await model.SaveAsync();")}

            return Json(new { result = "Redirect", url = Url.Action("Index", "#{name}") });
        }


        //
        // POST: /#{name}/Delete/5

        [HttpPost, ActionName("Delete")]
        public async Task<bool> Delete(#{keytype} id)
        {
            var result = await #{name_downcase}Repository.DeleteAsync(where: new {Id = id});
            return result;
        }

        #region #{name_downcase} data access

        [HttpPost]
        public JsonResult Get#{name}s()
        {
            var #{name_downcase}s = #{name_downcase}Repository.GetAll();

            var result = new {
                #{name_downcase}s = #{name_downcase}s
            };

            return Json(result);
        }

        [HttpPost]
        public async Task<JsonResult> Get#{name}(Guid id)
        {
            #{(get_repositories(model, 'use') if useRepositories)}
            #{init_view_model(model)}

            var result = new
            {
                #{name_downcase} = #{name_downcase}
            };

            return Json(result);
        }

        [HttpPost]
        public async Task<JsonResult> GetAll#{name}(int page_num, int rows_per_page)
        {
            var list = new List<dynamic>();
            var sortField = this.Request.Form["sorting[0][field]"];
            var sort = this.Request.Form["sorting[0][order]"];
            
            var totalRows = await #{name_downcase}Repository.ExecuteScalarAsync<int>("SELECT Count(Id) FROM #{name_downcase}", new Dictionary<string, object>());
            var registers = await #{name_downcase}Repository.GetManyAsync(
                new {},
                new {},
                Needletail.DataAccess.Engines.FilterType.AND,
                page_num - 1,
                rows_per_page
            );

            registers = (sort == "descending") ?
                registers.OrderByDescending(DynamicOrdering[sortField]) :
                registers.OrderBy(DynamicOrdering[sortField]);

            foreach (var row in registers)
            {
                var objId = row.Id.ToString();
                list.Add(new
                {   #{get_properties(model, 'object')},
                    edit = string.Format("<a href = \\"/#{name_downcase}/edit/{0}\\">Edit</a>", objId),
                    details = string.Format("<a href = \\"/#{name_downcase}/Details/{0}\\">Details</a>", objId),
                    delete = string.Format("<a href = \\"/#{name_downcase}/delete/{0}\\">Delete</a>", objId)
                });
            }
 
            return Json(new { total_rows = totalRows, page_data = list });;
        }

        //By default the Id is a Guid, change it to whatever you need
        public async Task<JsonResult> GetTextForAutocomplete(Guid id, string idField, string showField)
        {
            var found = (await #{name_downcase}Repository.GetManyAsync(
                where: string.Format("{0} = @id", idField),
                orderBy: "",
                args: new Dictionary<string, object> { { "id", id } },
                topN: null)).FirstOrDefault();
            if(found == null)
                return Json(new { name = "" });    
            
            var show = found.GetType().GetProperties().FirstOrDefault(p => p.Name.ToLower() == showField.ToLower());            
            return Json(new { name = show.GetValue(found) });
        }

        public async Task<JsonResult> Search(string query, string searchField, string idField, string showField, string order)
        {
            query = query.Trim();
            if (!query.StartsWith("%"))
                query = "%" + query;
            if (!query.EndsWith("%"))
                query += "%";
            var found = await #{name_downcase}Repository.GetManyAsync(
                where: string.Format("{0} like @query", searchField),
                orderBy: order + " DESC",
                args: new Dictionary<string, object> { { "query", query } },
                topN: null);

            if (found == null || found.Count() == 0)
                return Json(new List<object> { new { id = "00000000-0000-0000-0000-000000000000", name = string.Format("{0}: No results found", query.Replace("%","")) } });

            //create the object to return
            var allFound = new List<object>();
            var id = found.First().GetType().GetProperties().FirstOrDefault(p => p.Name.ToLower() == idField.ToLower());
            var show = found.First().GetType().GetProperties().FirstOrDefault(p => p.Name.ToLower() == showField.ToLower());
            if (id == null || show == null)
                throw new Exception("Id field or Show fields doest not belog to the entity");
            foreach (var f in found)
            { 
                allFound.Add(new { id = id.GetValue(f), name = show.GetValue(f) });
            }

            return Json(allFound);
        }

        #endregion
    }
}
template
end

def get_repositories model, action
    repositories = ""
    entity_name = model['name']
    entity_name_downcase = entity_name.downcase

    if action == "declaration"
        repositories += "
        #{entity_name}Repository #{entity_name.downcase}Repository;"    
    elsif action == "init"
        repositories += "
        #{entity_name_downcase}Repository = new #{entity_name}Repository();"
    elsif action == "use"
            repositories += "
        var #{entity_name_downcase} = await #{entity_name.downcase}Repository.GetSingleAsync(where: new {Id = id});
        #{entity_name_downcase} = #{entity_name_downcase} ?? new #{entity_name}();"        
    end 
        
    repositories
        
end

def init_view_model model
    name = model['name']
    name_downcase = name.downcase
    result = ""

    isVM =model.xpath("//entity").first['isViewModel'] 
    if isVM == 'True' || isVM == 'true'
        result = "
            var #{name_downcase} = new #{name}ViewModel();
            await #{name_downcase}.FillDataAsync(primaryKey: id);"
    end

    result
end

def get_has_ones model
has_ones = ""
model.xpath("//@HasOne").each do |node|
    main_entity_name = model['name']
    property_name = node
    id_name = node.parent.name

    nkg_obj = node.xpath("//entity")
    has_one = nkg_obj.search("entity[objectName=#{property_name}]")
    has_one_name = has_one.attribute('name')

    has_ones += "
        model.#{main_entity_name}.#{id_name} = Guid.NewGuid();
        model.#{property_name} = new #{has_one_name}(){Id = model.#{main_entity_name}.#{id_name}};"
end

has_ones
end

def get_properties model, type
    name_downcase = model['name'].downcase
    elements = model.at_xpath("fields").elements
    fields = ""

    elements.each do |node|    
        property_name = node.name

        case type
        when "dictionary"
            fields += "
            {\"#{property_name}\",opt => opt.#{property_name}},"
        when "object"
            fields += "
                    #{property_name} = row.#{property_name},"
        end
    end

    fields.chomp(',')

end