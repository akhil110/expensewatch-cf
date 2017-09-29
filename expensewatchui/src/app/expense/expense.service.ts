import { Injectable } from '@angular/core';
import { Http, Response, Headers, RequestOptions} from '@angular/http';
import { Observable } from 'rxjs/Observable';
import 'rxjs/add/operator/do';
import 'rxjs/add/operator/catch';
import 'rxjs/add/operator/map';
import 'rxjs/add/observable/throw';


@Injectable()
export class ExpenseService {

    public jwtToken: string;
    public apiurl: string;

    constructor(private http: Http) {
        const theUser: any = JSON.parse(localStorage.getItem('currentUser'));
        if (theUser) {
            this.jwtToken = theUser.token;
        }
        this.apiurl = 'http://localhost:8500/rest/api/expenseAPI';
    }

    saveExpense(userid, oExpense) {
        const headers = new Headers();
        headers.append('Content-Type', 'application/json');
        headers.append('Authorization', `${this.jwtToken}`);
        const options = new RequestOptions({ headers: headers });

        return this.http.post(`${this.apiurl}/expense/${userid}`, JSON.stringify(oExpense), options)
            .map((response: Response) => response.json())
            .catch(this.handleError);
    }

    getExpenses(userid, oExpense) {
        const headers = new Headers();
        headers.append('Content-Type', 'application/json');
        headers.append('Authorization', `${this.jwtToken}`);
        const options = new RequestOptions({ headers: headers });

        return this.http.post(`${this.apiurl}/expense/report/${userid}`, JSON.stringify(oExpense), options)
            .map((response: Response) => response.json())
            .catch(this.handleError);
    }

    getExpense(expid) {
        const headers = new Headers();
        headers.append('Content-Type', 'application/json');
        headers.append('Authorization', `${this.jwtToken}`);
        const options = new RequestOptions({ headers: headers });

        return this.http.get(`${this.apiurl}/expense/${expid}`, options)
            .map((response: Response) => response.json())
            .catch(this.handleError);
    }

    delExpense(expid) {
        const headers = new Headers();
        headers.append('Content-Type', 'application/json');
        headers.append('Authorization', `${this.jwtToken}`);
        const options = new RequestOptions({ headers: headers });

        return this.http.delete(`${this.apiurl}/expense/${expid}`, options)
            .map((response: Response) => response.json())
            .catch(this.handleError);
    }

     private handleError(error: Response) {
        console.error(error);
        return Observable.throw(error.json().error || 'Server error');
    }
}
