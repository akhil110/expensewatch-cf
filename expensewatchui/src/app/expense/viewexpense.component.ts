import { Component, OnInit, OnDestroy } from '@angular/core';
import { Router, ActivatedRoute } from '@angular/router';
import { ExpenseService } from './expense.service';
import { AuthService } from '../user/auth.service';
import { ToastrService } from '../common/toastr.service';
import { Subscription } from 'rxjs/Subscription';
import { IExpense } from './expense';

@Component({
  templateUrl: './viewexpense.component.html'
})

export class ViewexpenseComponent implements OnInit, OnDestroy {

  expense: IExpense;
  private sub: Subscription;

  constructor(
    private authService: AuthService,
    private expenseService: ExpenseService,
    private toastr: ToastrService,
    private route: ActivatedRoute,
    private router: Router) {
  }

  ngOnInit(): void {
    this.sub = this.route.params.subscribe(
      params => {
        const id = params['id'];
        this.getExpense(id);
      });
    }

    ngOnDestroy() {
      this.sub.unsubscribe();
    }

    getExpense(id) {
      this.expenseService.getExpense(id).subscribe(data => {
        if (data.success === false) {
          if (data.errcode) {
            this.authService.logout();
            this.router.navigate(['login']);
          }
          this.toastr.error(data.message);
        } else {
          if (data.data) {
            this.expense = JSON.parse(data.data)[0];
          } else {
            this.toastr.error('Expense id is incorrect in the URL');
          }
        }
      });
    }

    onBack(): void {
        this.router.navigate(['/report'], { queryParamsHandling: 'preserve' });
    }
}
