import { NgModule } from '@angular/core';
import { RouteReuseStrategy, ActivatedRouteSnapshot, DetachedRouteHandle, Routes, RouterModule } from '@angular/router';

import { RankingComponent } from './ranking/ranking.component';

const routes: Routes = [
  { path: 'ranking', component: RankingComponent },
  { path: '', redirectTo: '/ranking', pathMatch: 'full' }
];

export class CustomRouteReuseStategy implements RouteReuseStrategy {

  handlers: { [key: string]: DetachedRouteHandle } = {};

  shouldDetach(route: ActivatedRouteSnapshot): boolean {
    return !route.data.shouldNotReuse;
  }

  store(route: ActivatedRouteSnapshot, handle: {}): void {
    if (!route.data.shouldNotReuse) {
      this.handlers[route.routeConfig.path] = handle;
    }
  }

  shouldAttach(route: ActivatedRouteSnapshot): boolean {
    return !!route.routeConfig && !!this.handlers[route.routeConfig.path];
  }

  retrieve(route: ActivatedRouteSnapshot): {} {
    if (!route.routeConfig) return null;
    return this.handlers[route.routeConfig.path];
  }

  shouldReuseRoute(future: ActivatedRouteSnapshot, curr: ActivatedRouteSnapshot): boolean {
    return !future.data.shouldNotReuse;
  }

}

@NgModule({
  imports: [RouterModule.forRoot(routes)],
  exports: [RouterModule],
  providers: [
    { provide: RouteReuseStrategy, useClass: CustomRouteReuseStategy }
  ]
})
export class AppRoutingModule { }
