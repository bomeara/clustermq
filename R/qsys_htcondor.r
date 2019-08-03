#' HTCondor scheduler functions
#'
#' Derives from QSys to provide HTCondor-specific functions
#'
#' @keywords internal
#' @examples
#' \dontrun{
#' options(clustermq.scheduler="HTCONDOR")
#' library(clustermq)
#' library(foreach)
#' register_dopar_cmq(n_jobs=2, memory=1024) # accepts same arguments as `workers`
#' foreach(i=1:3) %dopar% sqrt(i) # this will be executed as jobs
#' }
HTCONDOR = R6::R6Class("HTCONDOR",
    inherit = QSys,

    public = list(
        initialize = function(..., template=getOption("clustermq.template", "HTCONDOR")) {
            super$initialize(..., template=template)
        },

        submit_jobs = function(...) {
            opts = private$fill_options(...)
            private$job_id = opts$job_name
            filled = private$fill_template(opts)
            success = system("condor_submit", input=filled, ignore.stdout=TRUE)
            if (success != 0) {
                print(filled)
                stop("Job submission failed with error code ", success)
            }
        },

        finalize = function(quiet=self$workers_running == 0) {
            if (!private$is_cleaned_up) {
                system(paste("condor_rm ", private$job_id),
                       ignore.stdout=quiet, ignore.stderr=quiet, wait=FALSE)
                private$is_cleaned_up = TRUE
            }
        }
    ),

    private = list(
        job_id = NULL
    )
)
