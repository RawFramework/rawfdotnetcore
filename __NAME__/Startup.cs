using Microsoft.Owin;
using Owin;

[assembly: OwinStartupAttribute(typeof(__NAME__.Startup))]
namespace __NAME__
{
    public partial class Startup
    {
        public void Configuration(IAppBuilder app)
        {
            ConfigureAuth(app);
        }
    }
}
