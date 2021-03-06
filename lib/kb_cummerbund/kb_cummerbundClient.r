library(jsonlite)
library(httr)

kb_cummerbundClient <- function(url, token = NULL, flatten = TRUE, 
        simplifyDataFrame = FALSE, simplifyVector = FALSE, simplifyMatrix = FALSE) {
    ret_client_object_ref <- list(url = url, token = token)

    ret_client_object_ref[['json_rpc_call']] <- function(method_name, param_list) {
        body_text = toJSON(
            list(
                id=1,version=unbox("1.1"),
                method=unbox(method_name),
                params=param_list
            )
        )
        resp <- POST(ret_client_object_ref[['url']],
            accept_json(),
            add_headers("Content-Type" = "application/json",
                "Authorization" = unbox(ret_client_object_ref[['token']])),
            body = body_text
        )
        parsed <- fromJSON(content(resp, "text"), 
            flatten=ret_client_object_ref[['flatten']], 
            simplifyDataFrame=ret_client_object_ref[['simplifyDataFrame']], 
            simplifyVector=ret_client_object_ref[['simplifyVector']], 
            simplifyMatrix=ret_client_object_ref[['simplifyMatrix']])
        if (resp[['status_code']] != 200) {
            error <- parsed[['error']]
            if (is.null(error)) {
                stop_for_status(resp)
            }
            message <- error[['error']]
            if (is.null(message)) {
                message <- error[['data']]
            }
            if (is.null(message)) {
                message <- error[['message']]
            }
            stop(message)
        }
        return(parsed[['result']])
    }

    ret_client_object_ref[['generate_cummerbund_plots']] <- function(cummerbundParams) {
        ret <- ret_client_object_ref[['json_rpc_call']]("kb_cummerbund.generate_cummerbund_plots", list(
                cummerbundParams
        ))
        return(ret[[1]])
    }

    ret_client_object_ref[['flatten']] <- flatten
    ret_client_object_ref[['simplifyDataFrame']] <- simplifyDataFrame 
    ret_client_object_ref[['simplifyVector']] <- simplifyVector
    ret_client_object_ref[['simplifyMatrix']] <- simplifyMatrix
    class(ret_client_object_ref) <- 'kb_cummerbundClient'
    return(ret_client_object_ref)
}
