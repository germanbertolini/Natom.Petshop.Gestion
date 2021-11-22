using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Natom.Petshop.Gestion.Entities.DTO.Auth
{
    public class LoginResultDTO
    {
        [JsonProperty("User")]
        public UserDTO User { get; set; }

        [JsonProperty("Token")]
        public string Token { get; set; }

        [JsonProperty("Permissions")]
        public List<string> Permissions { get; set; }
    }
}
