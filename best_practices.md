## Avoiding nil troubles


### Sources of nil
* User input
* Database/network records
* Uninitialized state
* Functions which could return nothing

### solving

* State machines
* Defaults
* Optional chaining
* Either monad
* Maybe monad
* Arrify


references
[Eric Elliot](https://medium.com/javascript-scene/handling-null-and-undefined-in-javascript-1500c65d51ae)


## Architecture

references
[clean architecture](https://www.youtube.com/watch?v=y3MWfPDmVqo)
[hexagonal architecture](https://www.youtube.com/watch?v=GZ9ic9QSO5U)

## Avdi recomendations

4 Stages:
  1. Gathering input
  2. Perform work
  3. Handling errors
  4. Delivering result

### Gathering input
Protect from nil
  => Array() .to_i, .to_s,  
  si tu codigo precisa un duck en el input pero no sabe que le pueden llegar a mandar  
  => ahi haces un wrapper sobre este input para hacer que sea lo que sea que te pasen
  este input se va a comportar como un duck  

  Si tu codigo tiene precondiciones sobre un input ejemplo (no acepto un string vacio)
  => hacer un assert que tire una exception o short circuit return NullResult if input is string vacio
  Avoid checking for nil => options.try(:foo) ==> Maybe(options).foo  
  Define a default value for handling nil cases.  
  Cuando te pasan datos u objetos por parametros estos deberian siempre obedecer un contrato siempre durante su utilizacion.  

### Perform work
=> focus on the job ==> chainig is great for that.  
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
