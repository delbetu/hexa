- [ ] Add postman for rest sign in
- [ ] Add gql for sign in
- [ ] gql endpoint for schema???
- [ ] Crear un Reporter que encapsule Raven ( Sentry ) y el logger de heroku??, que sea visible de todos lados??
- [ ] Los json fixtures que se generan por los tests, no sobrescribir los ids
- [ ] Seguir las reglas para evitar bugs de avdi grimm
  - [ ] Obligar a que se cumpla un contrato en diferentes etapas del procesamiento de datos.
        Si el contrato se cumple enotnces no existe el code smell switch-statement
        Etapas: Gathering input, doing the job, handling errors, Delivering result
  - [ ] Cuando te pasan datos u objetos por parametros estos deberian siempre obedecer un contrato siempre durante su utilizacion.  
         ### Para Respetar contrato en el input
        => Array() .to_i, .to_s,
        si tu codigo precisa un duck en el input pero no sabe que le pueden llegar a mandar
        => ahi haces un wrapper sobre este input para hacer que sea lo que sea que te pasen
        este input se va a comportar como un duck
        Si tu codigo tiene precondiciones sobre un input ejemplo (no acepto un string vacio)
        => hacer un assert que tire una exception o short circuit return NullResult if input is string vacio
        Avoid checking for nil => options.try(:foo) ==> Maybe(options).foo
        Define a default value for handling nil cases.  
         ### Para Perform work => focus on the job ==> chainig is great for that.
        Wrap the result of each step for example within an array y utilizar .map .inject ...
        Esto evita codigo para error handling.  
         ### Para Deliver result
        Always returns object that respect the contract
        return special case object, nullobect, or raise error
        never return nil  
         ### Handle failure
        Put the error handling at the end ==> Usar un bouncer method ==> do nothing or raise error
        es como un after hook, despues de que el codigo que nosotros queremos ejecuta, el resultado
        es tomado por nuestro bouncer_method y si retorno un valor invalido hacemos un raise ArgumentError
- [ ] test sign_up user creator adapter
- [ ] test sign_up email confirmator adapter
- [X] Testear e implementar el Mailer
- [x] Borrar los port
- [x] Borrar las interfaces
- [x] Sign Up improve error when email is already taken
- [x] Improve Crud
- [X] Sign up no esta guardando un hash en el password ( esta guardando el password en plano )
- [x] Postman el gql de signup user esta mal
