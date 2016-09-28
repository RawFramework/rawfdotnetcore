def api_controller_template model, keytype, entityNameSpace, root_namespace
    name = model['name']
    name_downcase = name.downcase
    
return <<template
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;
using System.Web.Script.Serialization;
using Newtonsoft.Json;
using #{@solution_name_sans_extension}.Repositories;
using #{entityNameSpace};
#{root_namespace}

namespace #{@solution_name_sans_extension}.Controllers.Api
{
    public class #{name}Controller : ApiController
    {

        #{name}Repository #{name_downcase}Repository;

        public #{name}Controller() {

            //Remove this line if you want to use dependency injection 
            
            #{name_downcase}Repository = new #{name}Repository();
        }


        // GET: api/#{name}
        public IEnumerable<#{name}> Get()
        {
            return #{name_downcase}Repository.GetAll();
        }

        // GET: api/#{name}/5
        public #{name} Get(#{keytype} id)
        {
            return #{name_downcase}Repository.GetSingle(where: new { Id = id }); ;
        }

        // POST: api/#{name}
        public #{keytype} Post([FromBody]#{name} model)
        {
            model.Id = #{keytype}.New#{keytype}();
            return #{name_downcase}Repository.Insert(model);
        }

        // PUT: api/#{name}/5
        public bool Put(#{keytype} id, [FromBody]#{name} model)
        {
            return #{name_downcase}Repository.UpdateWithWhere(values: model,
                            where: new { Id = id });
        }

        // DELETE: api/#{name}/5
        public bool Delete(#{keytype} id)
        {

            return #{name_downcase}Repository.Delete(where: new { Id = id });
        }
    }
}
template
end