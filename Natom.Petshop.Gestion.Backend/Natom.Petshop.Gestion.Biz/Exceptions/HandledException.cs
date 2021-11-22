using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Natom.Petshop.Gestion.Biz.Exceptions
{
    public class HandledException : Exception
    {
        public HandledException(string error) : base(error)
        { }
    }
}
