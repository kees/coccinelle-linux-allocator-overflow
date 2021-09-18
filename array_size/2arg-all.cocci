// Find an allocator call that can be converted into two size arguments.
@alloc_2arg@
position pos;
@@

    \(kmalloc\|
      kzalloc\|
      kmalloc_node\|
      kzalloc_node\|
      kvmalloc\|
      kvzalloc\|
      devm_kmalloc\|
      devm_kzalloc\)(...)@pos

// If we match these rules, the function is not being replaced. We're
// either ignoring (constants) or we're converting to a single argument.
@skip_2arg depends on alloc_2arg@
expression ALLOC;
expression THING1;
type TYPE1;
constant CONST1, CONST2, CONST3;
position pos = alloc_2arg.pos
@@

  ALLOC(...,
(
// non-changing cases, based on 1arg-all.cocci
// types must got first to avoid matching expressions.
	((sizeof(TYPE1)) * (CONST1))
|
	((sizeof(TYPE1)) + (CONST1))
|
	((sizeof(THING1)) * (CONST1))
|
	((sizeof(THING1)) + (CONST1))
|
	((CONST1) * (CONST2))
|
	((CONST1) + (CONST2))
|
	((sizeof(TYPE1)) * (CONST2) * (CONST3))
|
	((sizeof(TYPE1)) * (CONST2) + (CONST3))
|
	((sizeof(THING1)) * (CONST2) * (CONST3))
|
	((sizeof(THING1)) * (CONST2) + (CONST3))
|
	((CONST1) * (CONST2) * (CONST3))
|
	((CONST1) * (CONST2) + (CONST3))
|
// collapsed changes
-	((sizeof(u8)) * (COUNT))
+	COUNT
|
-	((sizeof(__u8)) * (COUNT))
+	COUNT
|
-	((sizeof(char)) * (COUNT))
+	COUNT
|
-	((sizeof(unsigned char)) * (COUNT))
+	COUNT
)
  )@pos

// For this, we've already not matched any of the skip rules, so on we go
// to convert the arguments.
@convert_1arg depends on never skip_2arg@
expression ALLOC;
position pos = alloc_2arg.pos
expression COUNT;
typedef u8;
typedef __u8;
type TYPE;
expression THING;
identifier COUNT_ID;
constant COUNT_CONST;
position funcpos;
@@

  ALLOC@funcpos(...,
(
-	((sizeof(TYPE)) * (COUNT_ID))
+	COUNT_ID, sizeof(TYPE)
|
-	((sizeof(THING)) * (COUNT_ID))
+	COUNT_ID, sizeof(THING)
|
-	((SIZE) * (COUNT))
+	COUNT, SIZE
)
  , ...)@pos

// We've swapped arguments from 1 to 2, but now we rename the function.
// XXX: I expect this will completely fail because we can't rename using
//      the earlier position.
@swap_allocator depends on convert_1arg@
position pos = convert_1arg.pos
@@

(
-	kmalloc
+	kmalloc_array
|
-	kzalloc
+	kcalloc
|
-	kmalloc_node
+	kmalloc_array_node
|
-	kzalloc_node
+	kcalloc_node
|
-	kvmalloc
+	kvmalloc_array
|
-	kvzalloc
+	kvcalloc
|
-	devm_kmalloc
+	devm_kmalloc_array
|
-	devm_kzalloc
+	devm_kcalloc
)
	@pos(...)
