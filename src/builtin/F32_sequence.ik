IokeGround Sequence = Origin mimic
Sequence mimic!(Mixins Enumerable)

Mixins Sequenced do(
  mapped = macro(call resendToReceiver(self seq))
  collected = macro(call resendToReceiver(self seq))
  sorted = macro(call resendToReceiver(self seq))
  sortedBy = macro(call resendToReceiver(self seq))
  folded = macro(call resendToReceiver(self seq))
  injected = macro(call resendToReceiver(self seq))
  reduced = macro(call resendToReceiver(self seq))
  filtered = macro(call resendToReceiver(self seq))
  selected = macro(call resendToReceiver(self seq))
  grepped = macro(call resendToReceiver(self seq))
  zipped = macro(call resendToReceiver(self seq))
  dropped = macro(call resendToReceiver(self seq))
  droppedWhile = macro(call resendToReceiver(self seq))
  rejected = macro(call resendToReceiver(self seq))
)



; Sequence Map do(
;   next = method(
;     n = @wrappedSequence next
;     x = transformValue(cell(:n))
;     cell(:x)
;   )

;   next? = method(
;     @wrappedSequence next?
;   )
; )


let(
  generateNextPMethod, method(takeCurrentObject, returnObject,
    method(@wrappedSequence next?)
    ),

  generateNextMethod, method(takeCurrentObject, returnObject,
    "calling generateNextMethod with: #{takeCurrentObject} and #{returnObject}" println
    vv = 'method(
      n = @wrappedSequence next
      x = transformValue(cell(:n))
    )
    "vv: #{vv}" println
    vv arguments[0] last -> returnObject
    "vv2: #{vv}" println
    vv evaluateOn(@)
    ),

  sequenceObject, dmacro(
    [takeCurrentObject, returnObject]
    s = Sequence Base mimic
    s next? = generateNextPMethod(takeCurrentObject, returnObject)
    s next  = generateNextMethod(takeCurrentObject, returnObject)
    s
    ),

  Sequence Base   = Sequence mimic
  Sequence Base create = method(wrappedSequence, context, messages,
    res = mimic
    res wrappedSequence = wrappedSequence
    res context = context
    res messages = messages
    if(messages length == 2,
      res lexicalBlock = LexicalBlock createFrom(messages, context)
    )
    res
  )

  Sequence Base transformValue = method(inputValue,
    if(messages length == 1,
      messages[0] evaluateOn(context, cell(:inputValue)),
      lexicalBlock call(cell(:inputValue))
    )
  )

  Sequence Map    = sequenceObject(true, cell(:x))
  Sequence Filter = Sequence mimic
  Sequence Fold   = Sequence mimic
  Sequence Sort   = Sequence mimic
  Sequence SortBy = Sequence mimic
  Sequence Zip    = Sequence mimic
  Sequence Reject = Sequence mimic
  Sequence Grep   = Sequence mimic
  Sequence Drop   = Sequence mimic
  Sequence DropWhile = Sequence mimic
)
