module Modulo
  class Router
    module ResponseCodes
      module Informational
        CONTINUE = 100
        SWITCHING_PROTOCOLS = 101
      end

      class Successful
        # Request succeeded.
        # GET: an entity corresponding to the requested resource is sent in the response
        # HEAD: the entity-header fields corresponding to the requested resource are sent in the response without any message-body
        # POST: an entity describing or containing the result of the action
        # TRACE: an entity containing the request message as received by the end server.
        OK = 200

        # Resource has been fully created
        # URI of resource is in the Location header field
        CREATED = 201

        # Request has been accepted but not processed.  Non-committal.
        ACCEPTED = 202

        NONAUTHORITATIVE_INFORMATION = 203

        NO_CONTENT = 204

        RESET_CONTENT = 205

        PARTIAL_CONTENT = 206
      end

      class Redirection
        MULTIPLE_CHOICES = 300

        MOVED_PERMANENTLY = 301

        FOUND = 302

        SEE_OTHER = 303

        NOT_MODIFIED = 304

        USE_PROXY = 305

        #SWITCH_PROXY = 306

        TEMPORARY_REDIRECT = 307
      end

      class ClientError
        BAD_REQUEST = 400
        UNAUTHORIZED = 401
        PAYMENT_REQUIRED = 402
        FORBIDDEN = 403
        NOT_FOUND = 404
        METHOD_NOT_ALLOWED = 405
        NOT_ACCEPTABLE = 406
        PROXY_AUTHENTICATION_REQUIRED = 407
        REQUEST_TIMEOUT = 408
        CONFLICT = 409
      end
    end

  end
end