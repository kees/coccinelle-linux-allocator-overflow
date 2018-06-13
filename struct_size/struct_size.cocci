// pkey_cache = kmalloc(sizeof *pkey_cache + tprops->pkey_tbl_len *
//                      sizeof *pkey_cache->table, GFP_KERNEL);
@@
identifier alloc =~ "kmalloc|kzalloc|kmalloc_node|kzalloc_node|vmalloc|vzalloc|kvmalloc|kvzalloc";
identifier VAR, ELEMENT;
expression COUNT;
@@

- alloc(sizeof(*VAR) + COUNT * sizeof(*VAR->ELEMENT)
+ alloc(struct_size(VAR, ELEMENT, COUNT)
  , ...)

// mr = kzalloc(sizeof(*mr) + m * sizeof(mr->map[0]), GFP_KERNEL);
@@
identifier alloc =~ "kmalloc|kzalloc|kmalloc_node|kzalloc_node|vmalloc|vzalloc|kvmalloc|kvzalloc";
identifier VAR, ELEMENT;
expression COUNT;
@@

- alloc(sizeof(*VAR) + COUNT * sizeof(VAR->ELEMENT[0])
+ alloc(struct_size(VAR, ELEMENT, COUNT)
  , ...)

// Same pattern, but can't trivially locate the trailing element name,
// or variable name.
@@
identifier alloc =~ "kmalloc|kzalloc|kmalloc_node|kzalloc_node|vmalloc|vzalloc|kvmalloc|kvzalloc";
expression BASEEXP, SUBEXP, COUNT;
type BASETYPE, SUBTYPE;
@@

(
- alloc(sizeof(BASEEXP) + COUNT * sizeof(SUBEXP)
+ alloc(CHECKME_struct_size(&BASEEXP, SUBEXP, COUNT)
  , ...)
|
- alloc(sizeof(BASETYPE) + COUNT * sizeof(SUBTYPE)
+ alloc(CHECKME_struct_size(BASETYPE, SUBTYPE, COUNT)
  , ...)
|
- alloc(sizeof(BASEEXP) + COUNT * sizeof(SUBTYPE)
+ alloc(CHECKME_struct_size(&BASEEXP, SUBTYPE, COUNT)
  , ...)
|
- alloc(sizeof(BASETYPE) + COUNT * sizeof(SUBEXP)
+ alloc(CHECKME_struct_size(BASETYPE, SUBEXP, COUNT)
  , ...)
)

// Direct reference to struct field.
@@
identifier alloc =~ "devm_kmalloc|devm_kzalloc|sock_kmalloc|f2fs_kmalloc|f2fs_kzalloc";
expression HANDLE;
identifier VAR, ELEMENT;
expression COUNT;
@@

- alloc(HANDLE, sizeof(*VAR) + COUNT * sizeof(*VAR->ELEMENT)
+ alloc(HANDLE, struct_size(VAR, ELEMENT, COUNT)
  , ...)

// mr = kzalloc(sizeof(*mr) + m * sizeof(mr->map[0]), GFP_KERNEL);
@@
identifier alloc =~ "devm_kmalloc|devm_kzalloc|sock_kmalloc|f2fs_kmalloc|f2fs_kzalloc";
expression HANDLE;
identifier VAR, ELEMENT;
expression COUNT;
@@

- alloc(HANDLE, sizeof(*VAR) + COUNT * sizeof(VAR->ELEMENT[0])
+ alloc(HANDLE, struct_size(VAR, ELEMENT, COUNT)
  , ...)

// Same pattern, but can't trivially locate the trailing element name,
// or variable name.
@@
identifier alloc =~ "devm_kmalloc|devm_kzalloc|sock_kmalloc|f2fs_kmalloc|f2fs_kzalloc";
expression HANDLE;
expression BASEEXP, SUBEXP, COUNT;
type BASETYPE, SUBTYPE;
@@

(
- alloc(HANDLE, sizeof(BASEEXP) + COUNT * sizeof(SUBEXP)
+ alloc(HANDLE, CHECKME_struct_size(&BASEEXP, SUBEXP, COUNT)
  , ...)
|
- alloc(HANDLE, sizeof(BASETYPE) + COUNT * sizeof(SUBTYPE)
+ alloc(HANDLE, CHECKME_struct_size(BASETYPE, SUBTYPE, COUNT)
  , ...)
|
- alloc(HANDLE, sizeof(BASEEXP) + COUNT * sizeof(SUBTYPE)
+ alloc(HANDLE, CHECKME_struct_size(&BASEEXP, SUBTYPE, COUNT)
  , ...)
|
- alloc(HANDLE, sizeof(BASETYPE) + COUNT * sizeof(SUBEXP)
+ alloc(HANDLE, CHECKME_struct_size(BASETYPE, SUBEXP, COUNT)
  , ...)
)

