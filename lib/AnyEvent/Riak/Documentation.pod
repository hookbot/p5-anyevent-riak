package AnyEvent::Riak::Documentation;

1;

=head1 METHODS

=head2 get_bucket

Get bucket properties request

=over

=item bucket

required, string

=item type

optional, string

=back

=head2 set_bucket

Set bucket properties request

=over

=item bucket

required, string

=item props

required, RpbBucketProps

=item type

optional, string

=back

=head2 reset_bucket

Reset bucket properties request

=over

=item bucket

required, string

=item type

optional, string

=back

=head2 get_bucket_type

Get bucket properties request

=over

=item type

required, string

=back

=head2 set_bucket_type

Set bucket properties request

=over

=item type

required, string

=item props

required, RpbBucketProps

=back

=head2 auth

Authentication request

=over

=item user

required, string

=item password

required, string

=back

=head2 set_client_id

=over

=item client_id

required, string

Client id to use for this connection

=back

=head2 get

Get Request - retrieve bucket/key

=over

=item bucket

required, string

=item key

required, string

=item r

optional, number

=item pr

optional, number

=item basic_quorum

optional, boolean

=item notfound_ok

optional, boolean

=item if_modified

optional, string

fail if the supplied vclock does not match

=item head

optional, boolean

return everything but the value

=item deletedvclock

optional, boolean

return the tombstone's vclock, if applicable

=item timeout

optional, number

=item sloppy_quorum

optional, boolean

Experimental, may change/disappear

=item n_val

optional, number

Experimental, may change/disappear

=item type

optional, string

Bucket type, if not set we assume the 'default' type

=back

=head2 put

Put request - if options.return_body is set then the updated metadata/data for the key will be returned.

=over

=item bucket

required, string

=item key

optional, string

=item vclock

optional, string

=item content

required, RpbContent

=item w

optional, number

=item dw

optional, number

=item return_body

optional, boolean

=item pw

optional, number

=item if_not_modified

optional, boolean

=item if_none_match

optional, boolean

=item return_head

optional, boolean

=item timeout

optional, number

=item asis

optional, boolean

=item sloppy_quorum

optional, boolean

Experimental, may change/disappear

=item n_val

optional, number

Experimental, may change/disappear

=item type

optional, string

Bucket type, if not set we assume the 'default' type

=back

=head2 del

Delete request

=over

=item bucket

required, string

=item key

required, string

=item rw

optional, number

=item vclock

optional, string

=item r

optional, number

=item w

optional, number

=item pr

optional, number

=item pw

optional, number

=item dw

optional, number

=item timeout

optional, number

=item sloppy_quorum

optional, boolean

Experimental, may change/disappear

=item n_val

optional, number

Experimental, may change/disappear

=item type

optional, string

Bucket type, if not set we assume the 'default' type

=back

=head2 list_buckets

List buckets request 

=over

=item timeout

optional, number

=item stream

optional, boolean

=item type

optional, string

Bucket type, if not set we assume the 'default' type

=back

=head2 list_keys

List keys in bucket request

=over

=item bucket

required, string

=item timeout

optional, number

=item type

optional, string

Bucket type, if not set we assume the 'default' type

=back

=head2 map_red

Map/Reduce request

=over

=item request

required, string

=item content_type

required, string

=back

=head2 index

Secondary Index query request

=over

=item bucket

required, string

=item index

required, string

=item qtype

required, one of 'eq', 'range'

=item key

optional, string

key here means equals value for index?

=item range_min

optional, string

=item range_max

optional, string

=item return_terms

optional, boolean

=item stream

optional, boolean

=item max_results

optional, number

=item continuation

optional, string

=item timeout

optional, number

=item type

optional, string

Bucket type, if not set we assume the 'default' type

=item term_regex

optional, string

=item pagination_sort

optional, boolean

Whether to use pagination sort for non-paginated queries=back

=head2 CS_bucket

 added solely for riak_cs currently for folding over a bucket and returning objects.

=over

=item bucket

required, string

=item start_key

required, string

=item end_key

optional, string

=item start_incl

optional, boolean

=item end_incl

optional, boolean

=item continuation

optional, string

=item max_results

optional, number

=item timeout

optional, number

=item type

optional, string

Bucket type, if not set we assume the 'default' type

=back

=head2 counter_update

Counter update request

=over

=item bucket

required, string

=item key

required, string

=item amount

required, sint64

=item w

optional, number

=item dw

optional, number

=item pw

optional, number

=item returnvalue

optional, boolean

=back

=head2 counter_get

 counter value

=over

=item bucket

required, string

=item key

required, string

=item r

optional, number

=item pr

optional, number

=item basic_quorum

optional, boolean

=item notfound_ok

optional, boolean

=back

=head1 RESPONSE OBJECTS

=head2 RpbErrorResp

Error response - may be generated for any Req

=over

=item errmsg

required, string

=item errcode

required, number

=back

=head2 RpbGetServerInfoResp

Get server info request - no message defined, just send RpbGetServerInfoReq message code

=over

=item node

optional, string

=item server_version

optional, string

=back

=head2 RpbGetBucketResp

Get bucket properties response

=over

=item props

required, RpbBucketProps

=back

=head2 RpbGetClientIdResp

Get ClientId Request - no message defined, just send RpbGetClientIdReq message code

=over

=item client_id

required, string

Client id in use for this connection

=back

=head2 RpbGetResp

Get Response - if the record was not found there will be no content/vclock

=over

=item content

repeated, RpbContent

=item vclock

optional, string

the opaque vector clock for the object

=item unchanged

optional, boolean

=back

=head2 RpbPutResp

Put response - same as get response with optional key if one was generated

=over

=item content

repeated, RpbContent

=item vclock

optional, string

the opaque vector clock for the object

=item key

optional, string

the key generated, if any

=back

=head2 RpbListBucketsResp

List buckets response - one or more of these packets will be sent the last one will have done set true (and may not have any buckets in it)

=over

=item buckets

repeated, string

=item done

optional, boolean

=back

=head2 RpbListKeysResp

List keys in bucket response - one or more of these packets will be sent the last one will have done set true (and may not have any keys in it)

=over

=item keys

repeated, string

=item done

optional, boolean

=back

=head2 RpbMapRedResp

Map/Reduce response one or more of these packets will be sent the last one will have done set true (and may not have phase/data in it)

=over

=item phase

optional, number

=item response

optional, string

=item done

optional, boolean

=back

=head2 RpbIndexResp

Secondary Index query response

=over

=item keys

repeated, string

=item results

repeated, RpbPair

=item continuation

optional, string

=item done

optional, boolean

=back

=head2 RpbCSBucketResp

 return for CS bucket fold

=over

=item objects

repeated, RpbIndexObject

=item continuation

optional, string

=item done

optional, boolean

=back

=head2 RpbCounterUpdateResp

Counter update response? No message | error response

=over

=item value

optional, sint64

=back

=head2 RpbCounterGetResp

Counter value response

=over

=item value

optional, sint64

=back

=head1 OTHER OBJECTS

=item key

required, string

Key/value pair - used for user metadata, indexes, search doc fields=item value

optional, string

=back

=item module

required, string

Module-Function pairs for commit hooks and other bucket properties that take functions=item function

required, string

=back

=item modfun

optional, RpbModFun

A commit hook, which may either be a modfun or a JavaScript named function=item name

optional, string

=back

=item n_val

optional, number

Bucket properties. Declared in riak_core_app=item allow_mult

optional, boolean

=item last_write_wins

optional, boolean

=item precommit

repeated, RpbCommitHook

=item has_precommit

optional, boolean

=item postcommit

repeated, RpbCommitHook

=item has_postcommit

optional, boolean

=item chash_keyfun

optional, RpbModFun

=item linkfun

optional, RpbModFun

Declared in riak_kv_app=item old_vclock

optional, number

=item young_vclock

optional, number

=item big_vclock

optional, number

=item small_vclock

optional, number

=item pr

optional, number

=item r

optional, number

=item w

optional, number

=item pw

optional, number

=item dw

optional, number

=item rw

optional, number

=item basic_quorum

optional, boolean

=item notfound_ok

optional, boolean

=item backend

optional, string

Used by riak_kv_multi_backend=item search

optional, boolean

Used by riak_search bucket fixup=item repl

optional, one of 'FALSE', 'REALTIME', 'FULLSYNC', 'TRUE'

Used by riak_repl bucket fixup=item search_index

optional, string

Search index=item datatype

optional, string

KV Datatypes=item consistent

optional, boolean

KV strong consistency=back

=item key

required, string

=item object

required, RpbGetResp

=back

=item value

required, string

Content message included in get/put responses. Holds the value and associated metadata=item content_type

optional, string

the media type/format

=item charset

optional, string

=item content_encoding

optional, string

=item vtag

optional, string

=item links

repeated, RpbLink

links to other resources

=item last_mod

optional, number

=item last_mod_usecs

optional, number

=item usermeta

repeated, RpbPair

user metadata stored with the object

=item indexes

repeated, RpbPair

user metadata stored with the object

=item deleted

optional, boolean

=back

=item bucket

optional, string

Link metadata=item key

optional, string

=item tag

optional, string

=back


