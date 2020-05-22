import { Component, ElementRef, Inject, AfterViewInit, ViewChild } from '@angular/core';
import { DomSanitizer } from '@angular/platform-browser';
import { MatDialogRef, MAT_DIALOG_DATA } from '@angular/material/dialog';

@Component({
  selector: 'app-image',
  templateUrl: './image.component.html',
  styleUrls: ['./image.component.scss']
})
export class ImageComponent implements AfterViewInit {

  constructor(@Inject(MAT_DIALOG_DATA) public image_url: any, public dialogRef: MatDialogRef<ImageComponent>, private sanitizer: DomSanitizer) {
    let plot = this.image_url.changingThisBreaksApplicationSecurity.split(',', 2);
    if(plot[0] == "data:image/svg+xml;base64") {
      this.image_svg = sanitizer.bypassSecurityTrustHtml(atob(plot[1]));
    }
  }

  ngAfterViewInit() {
    this.svgZoomUpdate();
  }

  svgZoomUpdate() {
    this.svgContainer.nativeElement.firstElementChild.style["max-width"] = this.zoomed ? 'none': '100%';
    this.svgContainer.nativeElement.firstElementChild.style["max-height"] = this.zoomed ? 'none': '100%';
  }

  public zoomed: boolean = false;
  public image_svg = null;

  @ViewChild('svgContainer', { static: false })
  public svgContainer: ElementRef;

}
