import { Component } from '@angular/core';
import { Output, EventEmitter } from '@angular/core'; 

@Component({
  selector: 'app-nav-menu',
  templateUrl: './nav-menu.component.html',
  styleUrls: ['./nav-menu.component.css']
})
export class NavMenuComponent {
  @Output() toggleSidebarEvent = new EventEmitter<boolean>();
  isSidebarExpanded = false;
  isExpanded = false;

  collapse() {
    this.isExpanded = false;
  }

  toggle() {
    this.isExpanded = !this.isExpanded;
  }

  onSidebarMenuClick() {
    this.isSidebarExpanded = !this.isSidebarExpanded;
    this.toggleSidebarEvent.emit(this.isSidebarExpanded);
  }
}
