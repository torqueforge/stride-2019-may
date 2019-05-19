class SamlController < DummyController
  attr_reader :saml_destination_path

  def create
    identity_provider = SamlIdentityProvider.for_name(params[:idp])

    saml_settings = OneLoginSamlSettings.for_saml_controller_create(
      create_saml_url(deployment_code: identity_provider.deployment_code),
      identity_provider.issuer,
      identity_provider.target_url,
      identity_provider.fingerprint
    )

    response = Response.for(identity_provider.issuer, params[:SAMLResponse])

    response.settings = saml_settings
    saml_identity = identity_provider.saml_identity_for_name_id(response.name_id)

    # MyObject.saml_identity
    # MyObject.identity_provider
    # MyObject.response

    if response.invalid?
      final_path = root_path
    else

      if saml_identity.account_id
        final_path = redirect_path
        log_in_as saml_identity.account
      else
        if consumer_application = saml_identity.consumer_application
          final_path = redirect_path
          session[ConsumerApplication::SESSION_KEY] = consumer_application.to_param
        else
          final_path = deployment_shortcode_path(identity_provider.deployment_code)
          session[:saml_attributes] = identity_provider.translated_attributes(response.attributes)
          session[:saml_identity_id] = saml_identity.to_param
        end
      end
    end

    if identity_provider.test_mode?
      @saml_destination_path = final_path
      @validation_errors = begin
                             response.validate!
                             nil
                           rescue OneLoginSamlValidationError => e
                             response_errors = e.message
                           end

      render 'test_interstitial'
    else
      redirect_to final_path
    end
  end
end
