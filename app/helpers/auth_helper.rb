module AuthHelper
  class AuthToken
    def self.encode(payload,exp=60.minute.from_now)
      payload[:exp] = exp.to_i
      JWT.encode(payload,"lol")
    end
    def self.decode(token)
      payload = JWT.decode(token,"lol")[0]
      DecodedAuthToken.new(payload)
    rescue
      nil
    end
  end

  # Clase de apoyo para la decodificacion del token
  class DecodedAuthToken < HashWithIndifferentAccess

    # Metodo de consulta para saver si el token actual es vigente
    def expired?
      self[:exp] <= Time.now.to_i
    end
  end

  # Clases destiandas para el manejo de errores (Excepciones)
  class NotAuthenticatedError < StandardError
  end

  class AuthenticationTimeoutError < StandardError
  end
end
