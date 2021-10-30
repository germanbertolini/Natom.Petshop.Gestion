import { Component, OnInit } from "@angular/core";
import { User } from "src/app/classes/models/user.model";

@Component({
  selector: '[sidebar-menu]',
  templateUrl: './nav-sidebar.component.html',
  styleUrls: ['./nav-sidebar.component.css']
})
export class NavSidebarComponent implements OnInit {
  user: User;

  ngOnInit(): void {

    $(".option-body").slideToggle();
    (<any>$(".option-header")).click(function() {
      var option = $(this).attr("option");
      $(".option-body[option='" + option + "']").slideToggle();
    });

    this.user = new User();
    this.user.first_name = "German";
    this.user.last_name = "Bertolini";
    this.user.picture_url = "https://lh3.googleusercontent.com/ogw/ADea4I77Za6iqEqbdUL2uqgk2F88wtfI43U8O3gxDBdbRg=s128-c-mo";
    this.user.email = "german.bertolini@gmail.com";
    this.user.registered_at = new Date('2020-12-28T00:00:00');
    this.user.business_name = "Natom";
    this.user.business_role_name = "Administrador";
    this.user.country_icon = "arg";
  }

}