// Find an allocator call that only ever uses a single size argument.
@alloc_1arg@
position pos;
@@

    \(vmalloc\|
      vzalloc\|
      vmalloc_node\|
      kvmalloc_node\|
      kvzalloc_node\|
      krealloc\|
      sock_kmalloc\|
      f2fs_kmalloc\|
      f2fs_kzalloc\|
      f2fs_kvmalloc\|
      f2fs_kvzalloc\|
      memdup_user\)(...)@pos

@convert_1arg depends on alloc_1arg@
expression ALLOC;
position pos = alloc_1arg.pos;
expression COUNT_EXP;
constant COUNT_CONST;
typedef u8;
typedef __u8;
identifier SIZE, STRIDE, COUNT;
expression THING1, THING2;
type TYPE1, TYPE2;
expression EXPR1, EXPR2, EXPR3;
constant CONST1, CONST2, CONST3;
@@

  ALLOC(...,
(
// Drop single-byte sizes and redundant parens.
-	((sizeof(u8)) * (COUNT_EXP))
+	COUNT_EXP
|
-	((sizeof(__u8)) * (COUNT_EXP))
+	COUNT_EXP
|
-	((sizeof(char)) * (COUNT_EXP))
+	COUNT_EXP
|
-	((sizeof(unsigned char)) * (COUNT_EXP))
+	COUNT_EXP
|
// 2-factor product with sizeof(type/expression) and identifier or constant.
	((sizeof(TYPE1)) * (COUNT_CONST))
|
	((sizeof(THING1)) * (COUNT_CONST))
|
	((CONST1) * (CONST2))
|
-	((sizeof(TYPE1)) * (COUNT_ID))
+	array_size(COUNT_ID, sizeof(TYPE1))
|
-	((sizeof(THING1)) * (COUNT_ID))
+	array_size(COUNT_ID, sizeof(THING1))
|
// 2-factor product, only identifiers.
-	((SIZE) * (COUNT))
+	array_size(COUNT, SIZE)
|
// 3-factor product with 1 sizeof(type) or sizeof(expression), with
-	((sizeof(TYPE1)) * (COUNT) * (STRIDE))
+	array3_size(COUNT, STRIDE, sizeof(TYPE1))
|
-	((sizeof(THING1)) * (COUNT) * (STRIDE))
+	array3_size(COUNT, STRIDE, sizeof(THING1))
|
// 3-factor product with 2 sizeof(variable), with redundant parens removed.
-	((sizeof(TYPE1)) * (sizeof(TYPE2)) * (COUNT))
+	array3_size(COUNT, sizeof(TYPE1), sizeof(TYPE2))
|
-	((sizeof(THING1)) * (sizeof(THING2)) * (COUNT))
+	array3_size(COUNT, sizeof(THING1), sizeof(THING2))
|
-	((sizeof(TYPE1)) * (sizeof(THING2)) * (COUNT))
+	array3_size(COUNT, sizeof(TYPE1), sizeof(THING2))
|
// 3-factor product, only identifiers, with redundant parens removed.
-	((COUNT) * (STRIDE) * (SIZE))
+	array3_size(COUNT, STRIDE, SIZE)
|
// Any remaining multi-factor products, first at least 3-factor products
// when they're not all constants...
	((sizeof(TYPE1)) * (CONST2) * (CONST3))
|
	((sizeof(THING1)) * (CONST2) * (CONST3))
|
	((CONST1) * (CONST2) * (CONST3))
|
-	((EXPR1) * (EXPR2) * (EXPR3))
+	array3_size(EXPR1, EXPR2, EXPR3)
|
// And then all remaining 2 factor products when nothing above matches
-	((EXPR1) * (EXPR2))
+	array_size(EXPR1, EXPR2)
)
  , ...)@pos


