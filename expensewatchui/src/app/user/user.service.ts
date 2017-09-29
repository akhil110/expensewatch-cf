import { Injectable } from '@angular/core';
import { Http, Response, Headers, RequestOptions} from '@angular/http';
import { Observable } from 'rxjs/Observable';
import 'rxjs/add/operator/do';
import 'rxjs/add/operator/catch';
import 'rxjs/add/operator/map';
import 'rxjs/add/observable/throw';

@Injectable()
export class UserService {

    public jwtToken: string;
    public apiurl: string;

    constructor(private http: Http) {
        const theUser: any = JSON.parse(localStorage.getItem('currentUser'));
        if (theUser) {
            this.jwtToken = theUser.token;
        }
        this.apiurl = 'http://localhost:8500/rest/api/expenseAPI';
    }

    register(oUser) {
        const headers = new Headers ({ 'Content-Type': 'application/json'});
        const options = new RequestOptions({headers: headers});

        return this.http.post(`${this.apiurl}/signup`, JSON.stringify(oUser), options)
            .map((response: Response) => response.json())
            .catch(this.handleError);
    }

    getUser(userid) {
        const headers = new Headers();
        headers.append('Content-Type', 'application/json');
        headers.append('Authorization', `${this.jwtToken}`);
        const options = new RequestOptions({ headers: headers });

        return this.http.get(`${this.apiurl}/user/${userid}`, options)
            .map((response: Response) => response.json())
            .catch(this.handleError);
    }

    updateUser(userid, oUser) {
        const headers = new Headers();
        headers.append('Content-Type', 'application/json');
        headers.append('Authorization', `${this.jwtToken}`);
        const options = new RequestOptions({ headers: headers });

        return this.http.put(`${this.apiurl}/user/${userid}`, JSON.stringify(oUser), options)
            .map((response: Response) => response.json())
            .catch(this.handleError);
    }

    updatePassword(userid, oUser) {
        const headers = new Headers();
        headers.append('Content-Type', 'application/json');
        headers.append('Authorization', `${this.jwtToken}`);
        const options = new RequestOptions({ headers: headers });

        return this.http.put(`${this.apiurl}/password/${userid}`, JSON.stringify(oUser), options)
            .map((response: Response) => response.json())
            .catch(this.handleError);
    }

     private handleError(error: Response) {
        console.error(error);
        return Observable.throw(error.json().error || 'Server error');
    }
}
