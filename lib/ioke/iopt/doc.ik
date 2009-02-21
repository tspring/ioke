IOpt documentation = #[Command line processing the Ioke way.

  Introduction.
 
  IOpt is a tool for command-line option analysis. It tries to take
  advantage from Ioke's homoiconic nature to make you write less.
  IOpt is inspired by similar tools like ruby's optparse, and tries 
  to make command line parsing as easy as possible for ioke programs,
  while still allowing a great degree of control.

  Features

  - Doen't impose an option style, by default IOpt provides support 
    for unix style options (short and long), but you can easily define
    how an option looks like for your application.

  - Interface for easily creating options that will store a cell on a given
    object, activate a value(methods, blocks, etc).

  - Option arguments can be any of those supported by Ioke, thus your
    options can take required arguments, optionals, keywords, and
    +rest, +:krest arguments just like any other ioke method.

  - IOpt support option priority, so that you can choose which flags
    should be handled before others (like --help or --version).
    Default priority is 0, more negative values are higher priority.
 
  Basic Usage.
     
     opt = IOpt mimic

     ;; print the opt object as text, showing the available options
     ;; By default an option's action is executed having the opt object
     ;; as receiver. (more on how to change this later)
     opt["--help"\] = method("Show help", @println. System exit)
     ;; set --help a negative priority so that its executed before
     ;; options with more a positive priority.
     opt["--help"\] priority = -10
       
     ;; Creating an option that takes one required argument:
     ;; this action would store the value on opt cell(:output)
     ;;   --output here       => opt output = "here"
     ;;   -o=/there           => opt output = "/there"
     ;;   -o21                => opt output = "21"
     opt["-o", "--output"\] = method("Set output file", file, @output = file)

     ;; Optional arguments are just as easy
     ;; will handle the following: 
     ;;    -s fancy    =>  opt style = "fancy"
     ;;    -sa         =>  opt style = "a"
     ;;    -s=simple   =>  opt style = "simple"
     opt["-s"\] = method("With style", style "neat", @style = style)

     ;; parse the arguments given to the ioke runtime.
     ;; IOpt will not modify the array given to the parse method,
     ;; this original input is later available at opt cell(:argv)
     opt parse(System programArguments)

     ;; Arguments that were not recognized as options nor 
     ;; were part of an option arguments can be accessed by
     opt programArguments

     ;; The original input given to the parse method is available at
     opt argv

  Action arguments.

  Actions (the code that handles an option) can be any Ioke activable
  value, methods, macros, etc. Because of this, your options can have
  any type of arguments supported by ioke: required, optional, keyword
  arguments, +rest and +:krest.

  Arguments are captured from the command line just before the option
  taking them and before any other option is found.

  The following is a complex example of an action taking all types of
  arguments:

      ;; This action can take any argument up until the following option.
      ;; e.g. 
      ;;
      ;;    --ioke bKey:10 hello say:me world aKey: 5 again
      ;;
      opt["--ioke"\] = method("Support ioke argument style",
            required, optional "defValue", +rest,
            aKey:, bKey: 22, +:krest,
         ;; illustrate how arguments were handled.
         required should == "hello"
         optional should == "world"
         rest should == ["again"\]
         aKey should == "5"
         bKey should == "10"
         krest should == { say: "me" })


  Specifing options in a DSL way.
      
  IOpt tries to make option definition as natural as possible, to
  this end, it provides the on macro.
  
  Suppose you have an object where you want to store a cell
  using an option
  
     ;; this will create a --file option taking one required 
     ;; argument. when called will store value on myObject cell(:file)
     opt on(myObject, "--file", "Which file should I use", :@file)

     ;; Or if you already have a method on myObject and would like
     ;; to expose it as an option, use something like the follwing.
     ;; This will generate a --my-method option taking arguments
     ;; as mandated by the method object.
     opt on(myObject, "--my-method", :myMethod)

     ;; Instead of giving myObject each time, you can use
     opt = IOpt on(myObject)
     opt on(\"--foo\", \"Set the foo\", :@foo)
     opt on(\"-b\", \"--activate-bar\", :bar)

     ;; If the last argument is not a symbol, then the on macro
     ;; creates a LexicalBlock to handle the option:
     opt on("--something", "-s", "The documentation", arg,
       thisLexicalScopeVar + arg)

  The Action object.

  When you define an option in IOpt, it will create a mimic of
  IOpt Action, these kind of objects know how to consume the
  arguments they need, the documentation and the receiver to 
  execute the action on.

  After creating an option, its action can be accessed like
  
     opt["--help"\] ;; => The action handling --help
     
  There are some things you can do with an action object:

     ;; ask for the options it handles
     opt["--help"\] flags ;; => ["--help", "-h"\]

     ;; define it's processing priority
     ;; (more negative values are higher priority)
     opt["--help"\] priority = -1

     ;; set the documentation displayed for --help
     ;; most of the times it is borrowed from the activable
     ;; value's documentation cell.
     opt["--help"\] documentation = "Display this help"

     ;; set the receiver object where to activate the action
     opt["--help"\] receiver = someOtherObject
       
     ;; change the arity for this action.
     ;; Most of the times this is borrowed from the activable
     ;; value, but if that is a macro, you will need to 
     ;; specify if your option can consume arguments from cli.
     ;; e.g. Suppose you have a macro on the app object.
     app weird = dmacro("Weird destructuring macro for CLI",
        [>one\]
        blabla ;; received one arg

        [>one, two\]
        something) ;; expected at most two args

     ;; Now, so that you can be abe to consume at most two arguments
     ;; from the command line, you need to specify the argumentsCode
     ;; that your macro would expect.
     opt on(app, :weird) argumentsCode = "a,b nil"

]; documentation
  