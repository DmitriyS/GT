/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package webapp.callback;

import com.yota.top.sdk.callback.*;

/**
 *
 * @author DSavin
 */
public class IdentityResultCallback<T> implements ResultCallback<T> {
    private AsyncResult<T> asyncResult;
 
    public AsyncResult<T> getAsyncResult() {
        return asyncResult;
    }
 
    @Override
    public void requestCompleted(AsyncResult<T> asyncResult) {
        this.asyncResult = asyncResult;
    }
}
