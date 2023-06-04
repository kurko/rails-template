# This lists the variables that we need when booting the application.
class AppEnvVars
  REQUIRED_KEYS_PER_CONTEXT = {
    essential: [
      "REDIS_URL"
    ],
    # A context here is just a name for grouping env variables. For example, we
    # could call this AWS if we were to list env vars related to AWS (e.g S3).
    #
    # This is used by bin/doctor as well to run diagnostics.
    #
    # "Some context" => [
    #   "SOME_KEY",
    # ]
  }

  def self.assert_evars_for_context(context_name)
    ::Dotenv.require_keys(
      *REQUIRED_KEYS_PER_CONTEXT[context_name]
    )
  end
end

AppEnvVars.assert_evars_for_context(:essential)
