import { Component } from '@angular/core';

import { Title }  from '@angular/platform-browser';
import { ActivatedRoute } from '@angular/router';

@Component({
  selector: 'app-root',
  templateUrl: './app.component.html',
  styleUrls: ['./app.component.scss']
})
export class AppComponent {
  title = 'napire-userweb';
  caption = '';

  constructor(private activatedRoute: ActivatedRoute, private titleService: Title) {
    this.activatedRoute.queryParams.subscribe(params => {
      this.caption = 'NaPiRE ' + (params['model'] ? params['model'] : '');
      this.titleService.setTitle(this.caption);
    });
  }
}
