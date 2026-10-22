# Netsuite

## Initialize <code class='post'>POST</code>

> The above command accepts a basic authentication header:

```
Authorization: Basic <base64 string>

base64 string is the base64-encoding of "username:password"
```

> The above command returns a JSON structured like this:

```json
{
  "data": {
    "auth_string": null
  },
  "metadata": {}
}
```

This endpoint enables the NetSuite integration. It does not create an integration user or return credentials: `auth_string` is always `null`.

<aside class="notice">
Only users with superuser role can call this endpoint.
</aside>

### HTTP Request

`https://example.procurify.com/api/v3/integrations/netsuite/initialize/`

### HTTP Response Status Code

201 Created

## Get Accounts <code class='get'>GET</code>

> The above command returns a JSON structured like this:

```json
{
  "data": [
    {
      "id": 1,
      "code": "1000",
      "description": "Supplies",
      "parent": null,
      "active": true,
      "account_type": "Expense",
      "external_id": "1234",
      "custom_fields": {}
    },
    {
      "id": 2,
      "code": "2000",
      "description": "Services",
      "parent": null,
      "active": true,
      "account_type": "Expense",
      "external_id": "4321",
      "custom_fields": {}
    }
  ],
  "metadata": {
    "pagination": {
      "count": 2,
      "next": null,
      "previous": null,
      "page_size": 10,
      "num_pages": 1,
      "current_page": 1
    }
  }
}
```

This endpoint retrieves a list of active accounts.

Without `status`, the list contains the accounts that have an object map for this integration, whatever its status. `status` filters by the object map status. It matches the status name, ignoring case: `pending`, `synced`, `error`, `unsynced`, `won't sync`, `ignore`, `manually synced` or `neutral`. An unrecognised value is ignored. `status=pending` also includes accounts that have no object map.

`show_all` with any value, including `false`, returns every active account and ignores `status`.

### HTTP Request

`https://example.procurify.com/api/v3/integrations/netsuite/accounts/`

### URL Parameters

Parameter | Description | Example
--------- | ----------- | ---------
STATUS | object map status name, for example `pending`, `synced` or `error` | `?status=pending`
CODE | the alphanumeric account code, **can be comma separated** | `?code=ABC123,DEF456,999`
SHOW_ALL | any value returns every active account, mapped or not | `?show_all=true`

### HTTP Response Status Code

200 OK

## Get Single Account Details <code class='get'>GET</code>

> The above command returns a JSON structured like this:

```json
{
  "data": {
    "id": 1,
    "code": "1000",
    "description": "Supplies",
    "parent": null,
    "active": true,
    "account_type": "Expense",
    "external_id": "1234",
    "custom_fields": {}
  },
  "metadata": {}
}
```

This endpoint retrieves a specific active account.

### HTTP Request

`https://example.procurify.com/api/v3/integrations/netsuite/accounts/<ACCOUNT_ID>/`

### HTTP Response Status Code

200 OK

404 Not Found — account does not exist or is inactive

## Create Account <code class='post'>POST</code>

> The above command accepts a body:

```json
{
  "code": 1234,
  "description": "Test Account",
  "account_type": 2,
  "external_id": 4321,
  "parent": null
}
```

> The above command returns a JSON structured like this:

```json
{
  "data": {
    "id": 24,
    "code": "1234",
    "description": "Test Account",
    "parent": null,
    "active": true,
    "account_type": "Expense",
    "external_id": "4321",
    "custom_fields": {}
  },
  "metadata": {}
}
```

This endpoint creates an account, or updates the existing account with the same `code`.

An existing account with that `code` is updated from the request and made active, even if it was inactive. Its object map is set to `external_id`. The response is `201 Created` in both cases.

Every field is set from the request. Leaving out `parent` clears the account's parent.

`account_type` is sent as an ID and returned as its name, for example `"Expense"`.

### HTTP Request

`https://example.procurify.com/api/v3/integrations/netsuite/accounts/`

### HTTP Response Status Code

201 Created

400 Bad Request — the request updates an existing account and another active account already uses the code (`ACCOUNT_CODE_EXISTS`)

### Arguments

<code>code</code><span class="required-tag">required</span><br />
Account code.

<code>description</code><span class="required-tag">required</span><br />
Account code description. Send an empty string for no description.

<code>account_type</code><span class="required-tag">required</span><br />
Type of the account code.

Types | ID
--------- | -----------
ASSETS | 0
LIABILITY | 1
EXPENSE | 2
INCOME | 3
EQUITY | 4
OTHER | 5

<code>parent</code><br />
ID of the parent account code. Left out or `null` means no parent.

<code>external_id</code><span class="required-tag">required</span><br />
ID of the integration object.

## Update Account <code class='put'>PUT</code>

> The above command accepts a body:

```json
{
  "code": 1234,
  "description": "Test Account",
  "account_type": 2,
  "external_id": 4321,
  "parent": null
}
```

> The above command returns a JSON structured like this:

```json
{
  "data": {
    "id": 1,
    "code": "1234",
    "description": "Test Account",
    "parent": null,
    "active": true,
    "account_type": "Expense",
    "external_id": "4321",
    "custom_fields": {}
  },
  "metadata": {}
}
```

This endpoint updates a specific account and makes it active, even if it was inactive.

Every field is set from the request. Leaving out `parent` clears the account's parent.

`external_id` is required but not used: the account's object map is not changed. To link the account to a different NetSuite record, use Upsert Object Map.

### HTTP Request

`https://example.procurify.com/api/v3/integrations/netsuite/accounts/<ACCOUNT_ID>/`

### URL Parameters

Parameter | Description
--------- | -----------
ACCOUNT_ID | ID of the account being updated

### HTTP Response Status Code

200 OK

400 Bad Request — another active account already uses the code (`ACCOUNT_CODE_EXISTS`)

### Arguments

<code>code</code><span class="required-tag">required</span><br />
Account code.

<code>description</code><span class="required-tag">required</span><br />
Account code description. Send an empty string for no description.

<code>account_type</code><span class="required-tag">required</span><br />
Type of the account code.

Types | ID
--------- | -----------
ASSETS | 0
LIABILITY | 1
EXPENSE | 2
INCOME | 3
EQUITY | 4
OTHER | 5

<code>parent</code><br />
ID of the parent account code. Left out or `null` clears the parent.

<code>external_id</code><span class="required-tag">required</span><br />
ID of the integration object. Validated but not stored.

## Delete Account <code class='delete'>DELETE</code>

This endpoint soft deletes a specific account and its child accounts. They are deactivated, and the budgets that use them are removed.

Their codes are renamed to `DEL_<ID>_<TIMESTAMP>_<CODE>`, cut to 50 characters, which frees the code. A later Create Account with the same code creates a new account instead of bringing back the deleted one.

### HTTP Request

`https://example.procurify.com/api/v3/integrations/netsuite/accounts/<ACCOUNT_ID>/`

### URL Parameters

Parameter | Description
--------- | -----------
ACCOUNT_ID | ID of the account being deleted

### HTTP Response Status Code

204 No Content

## Get Payment Terms <code class='get'>GET</code>

> The above command returns a JSON structured like this:

```json
{
  "data": [
    {
      "id": 13,
      "name": "New term",
      "description": "",
      "external_id": "haha",
      "custom_fields": {}
    },
    {
      "id": 14,
      "name": "New term 2",
      "description": "",
      "external_id": "haha 2",
      "custom_fields": {}
    }
  ],
  "metadata": {
    "pagination": {
      "count": 2,
      "next": null,
      "previous": null,
      "page_size": 10,
      "num_pages": 1,
      "current_page": 1
    }
  }
}
```

This endpoint retrieves a list of active payment terms.

Without `status`, the list contains the payment terms that have an object map for this integration, whatever its status. `status` filters by the object map status. It matches the status name, ignoring case: `pending`, `synced`, `error`, `unsynced`, `won't sync`, `ignore`, `manually synced` or `neutral`. An unrecognised value is ignored.

`show_all` with any value, including `false`, returns every active payment term and ignores `status`.

### HTTP Request

`https://example.procurify.com/api/v3/integrations/netsuite/payment-terms/`

### URL Parameters

Parameter | Description | Example
--------- | ----------- | ---------
STATUS | object map status name, for example `pending`, `synced` or `error` | `?status=pending`
SHOW_ALL | any value returns every active payment term, mapped or not | `?show_all=true`

### HTTP Response Status Code

200 OK

## Get Single Payment Term Details <code class='get'>GET</code>

> The above command returns a JSON structured like this:

```json
{
  "data": {
    "id": 14,
    "name": "New term 2",
    "description": "",
    "external_id": "haha 2",
    "custom_fields": {}
  },
  "metadata": {}
}
```

This endpoint retrieves a specific active payment term.

### HTTP Request

`https://example.procurify.com/api/v3/integrations/netsuite/payment-terms/<PAYMENT_TERM_ID>/`

### HTTP Response Status Code

200 OK

404 Not Found — payment term does not exist or is inactive

## Create Payment Term <code class='post'>POST</code>

> The above command accepts a body:

```json
{
  "name": "New term 2",
  "description": "This describes me",
  "external_id": "haha 2"
}
```

> The above command returns a JSON structured like this:

```json
{
  "data": {
    "id": 14,
    "name": "New term 2",
    "description": "This describes me",
    "external_id": "haha 2",
    "custom_fields": {}
  },
  "metadata": {}
}
```

This endpoint creates a payment term, or updates the existing payment term with the same `name`.

An existing payment term with that `name` is updated from the request and made active, including one removed with Delete Payment Term. Its object map is set to `external_id`. The response is `201 Created` in both cases.

Leaving out `description` sets it to an empty string.

### HTTP Request

`https://example.procurify.com/api/v3/integrations/netsuite/payment-terms/`

### HTTP Response Status Code

201 Created

### Arguments

<code>name</code><span class="required-tag">required</span><br />
Name of the payment term

<code>description</code><br />
Payment Term description. Left out, it is set to an empty string.

<code>external_id</code><span class="required-tag">required</span><br />
ID of the integration object.

## Update Payment Term <code class='put'>PUT</code>

> The above command accepts a body:

```json
{
  "name": "New term 2",
  "description": "This describes me",
  "external_id": "haha 2"
}
```

> The above command returns a JSON structured like this:

```json
{
  "data": {
    "id": 14,
    "name": "New term 2",
    "description": "This describes me",
    "external_id": "haha 2",
    "custom_fields": {}
  },
  "metadata": {}
}
```

This endpoint updates a specific payment term and makes it active, even if it was removed with Delete Payment Term.

Leaving out `description` sets it to an empty string.

`external_id` is required but not used: the payment term's object map is not changed. To link the payment term to a different NetSuite record, use Upsert Object Map.

Renaming a payment term to a name another payment term already has fails with the message `A different payment term named '<NAME>' already exists.`

### HTTP Request

`https://example.procurify.com/api/v3/integrations/netsuite/payment-terms/<PAYMENT_TERM_ID>/`

### URL Parameters

Parameter | Description
--------- | -----------
PAYMENT_TERM_ID | ID of the payment term being updated

### HTTP Response Status Code

200 OK

400 Bad Request — another payment term already has the name

### Arguments

<code>name</code><span class="required-tag">required</span><br />
Name of the payment term

<code>description</code><br />
Payment Term description. Left out, it is set to an empty string.

<code>external_id</code><span class="required-tag">required</span><br />
ID of the integration object. Validated but not stored.

## Delete Payment Term <code class='delete'>DELETE</code>

This endpoint soft deletes a specific payment term. It is deactivated and no longer returned by Get Payment Terms. Create Payment Term with the same name, or Update Payment Term, brings it back.

### HTTP Request

`https://example.procurify.com/api/v3/integrations/netsuite/payment-terms/<PAYMENT_TERM_ID>/`

### URL Parameters

Parameter | Description
--------- | -----------
PAYMENT_TERM_ID | ID of the payment term being deleted

### HTTP Response Status Code

204 No Content

## Get Content Types <code class='get'>GET</code>

> The above command returns a JSON structured like this:

```json
{
  "data": [
    {
      "id": 180,
      "app_label": "ap",
      "model": "bill"
    },
    {
      "id": 185,
      "app_label": "ap",
      "model": "item"
    },
    {
      "id": 23,
      "app_label": "procurify",
      "model": "po"
    },
    {
      "id": 280,
      "app_label": "receipt",
      "model": "item"
    }
  ],
  "metadata": {}
}
```

This endpoint retrieves the content types used by the integration: bills, bill lines, purchase orders and item receipt lines. The list is not paginated.

### HTTP Request

`https://example.procurify.com/api/v3/integrations/netsuite/content-types/?model=<MODEL>`

### URL Parameters

Parameter | Description
--------- | -----------
MODEL | Filter content types by model name

### HTTP Response Status Code

200 OK

## Get PO Custom Field <code class='get'>GET</code>

> The above command returns a JSON structured like this:

```json
{
  "data": [
    {
      "id": 54,
      "field_label": "Weight",
      "field_model": "po",
      "field_required": false
    }
  ],
  "metadata": {
    "pagination": {
      "count": 1,
      "next": null,
      "previous": null,
      "page_size": 10,
      "num_pages": 1,
      "current_page": 1
    }
  }
}
```

This endpoint retrieves a list of the active purchase order custom fields.

### HTTP Request

`https://example.procurify.com/api/v3/integrations/netsuite/custom-fields/purchase-orders/`

### HTTP Response Status Code

200 OK

## Upsert PO Custom Field Value <code class='post'>POST</code>

> The above command accepts a body:

```json
{
  "purchase_order_id": 1,
  "custom_field_id": 1,
  "custom_field_value": "Test"
}
```

> The above command returns a JSON structured like this:

```json
{
  "data": {
    "purchase_order_id": 1,
    "custom_field_id": 1,
    "custom_field_value": "Test"
  },
  "metadata": {}
}
```

This endpoint sets a custom field value on a purchase order. `PUT` to the same URL behaves the same way.

### HTTP Request

`https://example.procurify.com/api/v3/integrations/netsuite/custom-fields/purchase-orders/`

### HTTP Response Status Code

201 Created

### Arguments

<code>purchase_order_id</code><span class="required-tag">required</span><br />
Purchase order ID.

<code>custom_field_id</code><span class="required-tag">required</span><br />
PO custom field ID.

<code>custom_field_value</code><span class="required-tag">required</span><br />
Set custom field value for the purchase order.

## Get Object Maps <code class='get'>GET</code>

> The above command returns a JSON structured like this:

```json
{
  "data": [
    {
      "id": 1,
      "object_id": 151,
      "status": 1,
      "content_type": 23,
      "external_id": "",
      "datetime_last_synced": "2020-01-02T10:15:00-08:00"
    },
    {
      "id": 2,
      "object_id": 1,
      "status": 1,
      "content_type": 23,
      "external_id": "",
      "datetime_last_synced": "2020-01-02T10:15:00-08:00"
    }
  ],
  "metadata": {
    "pagination": {
      "count": 2,
      "next": null,
      "previous": null,
      "page_size": 10,
      "num_pages": 1,
      "current_page": 1
    }
  }
}
```

This endpoint retrieves a list of this integration's object maps.

### HTTP Request

`https://example.procurify.com/api/v3/integrations/netsuite/object-maps/?status=<STATUS>`

### URL Parameters

Parameter | Description
--------- | -----------
STATUS | object map status ID, for example `0`. See the status table under Upsert Object Map. Status names such as `pending` are not accepted.
OBJECT_ID | ID of the Procurify object
CONTENT_TYPE | ID of the content type
EXTERNAL_ID | part of the external ID, ignoring case

### HTTP Response Status Code

200 OK

## Upsert Object Map <code class='post'>POST</code>

> The above command accepts a body:

```json
{
  "object_id": 151,
  "content_type": 23,
  "status": 1,
  "external_id": "1234",
  "message": "Error Message"
}
```

> The above command returns a JSON structured like this:

```json
{
  "data": {
    "id": 1,
    "object_id": 151,
    "status": 1,
    "content_type": 23,
    "external_id": "1234",
    "datetime_last_synced": "2020-01-02T10:15:00-08:00"
  },
  "metadata": {}
}
```

This endpoint creates or updates the object map for a Procurify object. The object map is found by `content_type` and `object_id`.

When `status` is left out, it is set to synced (`1`) if `external_id` is sent. Otherwise a new object map is pending (`0`) and an existing one becomes unsynced (`3`). When `external_id` is left out, an existing object map keeps its external ID.

When `message` is sent, it is saved to the integration logs: as an error when `status` is `2`, otherwise as a success.

### HTTP Request

`https://example.procurify.com/api/v3/integrations/netsuite/object-maps/`

### HTTP Response Status Code

201 Created

404 Not Found — `content_type` or `object_id` does not exist

### Arguments

<code>object_id</code><span class="required-tag">required</span><br />
ID of the Procurify object.

<code>content_type</code><span class="required-tag">required</span><br />
ID of Procurify content_type.

<code>status</code><br />
Object map status.

Status | ID
--------- | -----------
PENDING | 0
SYNCED | 1
ERROR | 2
UNSYNCED | 3
WON'T SYNC | 4
IGNORE | 5
MANUALLY SYNCED | 6
NEUTRAL | 7

<code>external_id</code><br />
ID of the integration object.

<code>message</code><br />
Optional message to save to integration logs.

## Delete Object Map <code class='delete'>DELETE</code>

This endpoint deletes a specific object map.

### HTTP Request

`https://example.procurify.com/api/v3/integrations/netsuite/object-maps/<OBJECT_MAP_ID>/`

### URL Parameters

Parameter | Description
--------- | -----------
OBJECT_MAP_ID | ID of the object map being deleted

### HTTP Response Status Code

204 No Content

## Get Purchase Orders <code class='get'>GET</code>

> The above command returns a JSON structured like this:

```json
{
  "data": [
    {
      "id": 52,
      "uuid": "8325e590-3b53-11e7-bfdd-021a9831e76d",
      "purchase_order_no": "",
      "transaction_date": "2017-05-17T15:52:33-07:00",
      "due_date": "2017-05-16T23:00:00-07:00",
      "total": "80.00",
      "created_by": {
        "id": 15,
        "first_name": "Joe",
        "last_name": "Smith",
        "email": "joesmith@test.com"
      },
      "line_items": [
        {
          "id": 193,
          "name": "Whiteout",
          "quantity": "10.00000",
          "unit_cost": "8.00",
          "unit_type": "each",
          "amount": "80.00",
          "currency": {
            "id": 3,
            "name": "USD",
            "rate": "1.000000",
            "active": true,
            "description": "",
            "base": true,
            "external_id": null,
            "custom_fields": {}
          },
          "account": {
            "id": 1,
            "code": "1000",
            "description": "Supplies",
            "parent": null,
            "active": true,
            "account_type": "Expense",
            "external_id": null,
            "custom_fields": {}
          },
          "department": {
            "id": 1,
            "name": "Accounting",
            "branch_id": 1,
            "active": true,
            "external_id": null,
            "custom_fields": {}
          },
          "location": {
            "id": 1,
            "name": "Glenn Research Center",
            "url": "www.nasa.gov/centers/glenn/home/",
            "phone_one": "(216) 433-4000",
            "fax": "",
            "email": "",
            "primary_billing_address": {
              "id": 1,
              "name": "Glenn Research Center",
              "address_line_one": "21000 Brookpark Rd, Cleveland",
              "city": "Cleveland",
              "postal_code": "44135",
              "state_province": "OH",
              "country": "USA"
            },
            "primary_shipping_address": {
              "id": 2,
              "name": "Glenn Research Center",
              "address_line_one": "21000 Brookpark Rd, Cleveland",
              "city": "Cleveland",
              "postal_code": "44135",
              "state_province": "OH",
              "country": "USA"
            },
            "language": 1,
            "location_timezone": "America/Vancouver",
            "active": true,
            "external_id": null,
            "custom_fields": {}
          },
          "catalog_item": {
            "id": 4,
            "name": "Whiteout",
            "unit_type": "Dozen",
            "vendor": 6,
            "account_code": 1,
            "internal_sku": "29382",
            "active": true,
            "description": "",
            "product_url": null,
            "currency": 1,
            "cost": "8.00000000",
            "external_id": null,
            "custom_fields": {}
          },
          "memo": "",
          "last_approver": {
            "id": 15,
            "first_name": "Kathryn",
            "last_name": "Hire",
            "email": "kathryn.hire@redshift7.com"
          },
          "requester": {
            "id": 7,
            "first_name": "Some",
            "last_name": "Guy",
            "email": "someguy@procurify.com"
          },
          "external_id": null,
          "custom_fields": {},
          "order_description": "Order with Procurify"
        }
      ],
      "vendor": {
        "id": 6,
        "name": "5 STAR",
        "active": true,
        "address_line_one": "55 West Hampton Ave",
        "address_line_two": "",
        "postal_code": "JKF 345",
        "city": "Toronto",
        "state_province": "Ontario",
        "country": "Canada",
        "email": "purchasing@fivestarcanada.com",
        "alt_email": null,
        "contact": "Ivan Improve",
        "phone": "930-456-8700",
        "alt_phone": "",
        "fax": "",
        "comments": "Notebooks and canvas supplier.",
        "url": "http://fivestarbooks.com/",
        "payment_term": "n 30",
        "shipping_term": "FOB",
        "vendor_external_id": null,
        "external_id": null,
        "custom_fields": {}
      },
      "shipping_address": {
        "contact_name": "Neil Armstrong",
        "address_line_one": "21000 Brookpark Rd, Cleveland",
        "city": "Cleveland",
        "state_province": "OH",
        "country": "USA",
        "postal_code": "44135"
      },
      "shipping_method": {
        "id": 5,
        "name": "FedEX",
        "description": "FedEX",
        "external_id": null,
        "custom_fields": {}
      },
      "shipping_term": {
        "id": 4,
        "name": "FOB",
        "description": "FOB",
        "external_id": null,
        "custom_fields": {}
      },
      "payment_term": {
        "id": 11,
        "name": "n 30",
        "description": "n 30",
        "external_id": null,
        "custom_fields": {}
      },
      "subtotal": "80.00",
      "freight": "0.00",
      "other": "0.00",
      "discount": "0.00",
      "tax": "0.00",
      "memo": "",
      "external_id": "9999",
      "custom_fields": {
        "Weight": null,
        "New Field": null
      }
    }
  ],
  "metadata": {
    "pagination": {
      "count": 1,
      "next": null,
      "previous": null,
      "page_size": 10,
      "num_pages": 1,
      "current_page": 1
    }
  }
}
```

This endpoint retrieves a list of purchase orders. Purchase orders paid by credit card are not included.

### HTTP Request

`https://example.procurify.com/api/v3/integrations/netsuite/purchase-orders/?status=pending,ignore&transaction_date=2020-01-02`

### URL Parameters

#### status

Use this field to get purchase orders of a certain status. Multiple statuses can be combined using comma-separation. Without it, purchase orders of every status are returned. Any other value fails with 400 `INVALID_STATUS`.

Value       | Description
----------- | -----------
all         | Get all records, whatever their status (the default)
pending     | Get all records that need to be processed in NS (a combination of new/updated/deleted)
synced      | Get all synced records previously successfully synced
error       | Get all records that encountered an error during its most recent sync
ignore      | Get all records that are not meant to sync over to NS. These are usually records that exist before initialization.

#### id

Try it out! `?id=1234` will get you PO with id=1234. **Can be comma separated**: `?id=1234,1235`

#### transaction_date

Try it out! `?transaction_date=2020-03-24` will get you POs with a transaction date on or after March 24th of 2020

#### has_unsynced_receipts

`?has_unsynced_receipts=true` will get you POs that have pending item receipt lines

### HTTP Response Status Code

200 OK

## Get Item Receipt Lines <code class='get'>GET</code>

> The above command returns a JSON structured like this:

```json
{
  "data": [
    {
      "id": 24,
      "name": "Whiteout",
      "order_item_id": 193,
      "purchased_quantity": "10.00000",
      "received_quantity": "5.00000",
      "receive_history": [
        {
          "received_quantity": "3.00000",
          "timestamp": "2019-11-28T12:31:57.735000-08:00"
        },
        {
          "received_quantity": "2.00000",
          "timestamp": "2019-11-28T12:32:17.234000-08:00"
        },
        {
          "received_quantity": "3.00000",
          "timestamp": "2019-11-28T12:32:38.206000-08:00"
        },
        {
          "received_quantity": "2.00000",
          "timestamp": "2019-11-28T12:33:16.307000-08:00"
        },
        {
          "received_quantity": "5.00000",
          "timestamp": "2019-11-28T12:49:25.943000-08:00"
        }
      ],
      "purchase_order": {
        "id": 52,
        "purchase_order_no": "",
        "uuid": "8325e590-3b53-11e7-bfdd-021a9831e76d",
        "external_id": "9999",
        "custom_fields": {
          "Weight": null,
          "New Field": null
        }
      },
      "created_at": "2019-11-28T12:31:57.735536-08:00",
      "updated_at": "2019-11-28T12:49:25.943330-08:00",
      "last_synced_info": {
        "synced_at": "2019-11-28T12:49:10.912734-08:00",
        "received_quantity": "2.00000",
        "delta": "3.00000"
      },
      "external_id": "9999",
      "custom_fields": {}
    },
    {
      "id": 25,
      "name": "Whiteout",
      "order_item_id": 193,
      "purchased_quantity": "10.00000",
      "received_quantity": "1.00000",
      "receive_history": [
        {
          "received_quantity": "3.00000",
          "timestamp": "2019-11-28T12:32:00.199000-08:00"
        },
        {
          "received_quantity": "4.00000",
          "timestamp": "2019-11-28T12:32:20.390000-08:00"
        },
        {
          "received_quantity": "3.00000",
          "timestamp": "2019-11-28T12:32:41.805000-08:00"
        },
        {
          "received_quantity": "4.00000",
          "timestamp": "2019-11-28T12:33:18.868000-08:00"
        },
        {
          "received_quantity": "1.00000",
          "timestamp": "2019-11-28T12:49:28.888000-08:00"
        }
      ],
      "purchase_order": {
        "id": 52,
        "purchase_order_no": "",
        "uuid": "8325e590-3b53-11e7-bfdd-021a9831e76d",
        "external_id": "9999",
        "custom_fields": {
          "Weight": null,
          "New Field": null
        }
      },
      "created_at": "2019-11-28T12:32:00.199650-08:00",
      "updated_at": "2019-11-28T12:49:28.888547-08:00",
      "last_synced_info": {
        "synced_at": "2019-11-28T12:49:08.573131-08:00",
        "received_quantity": "4.00000",
        "delta": "-3.00000"
      },
      "external_id": "9999",
      "custom_fields": {}
    }
  ],
  "metadata": {
    "pagination": {
      "count": 2,
      "next": null,
      "previous": null,
      "page_size": 10,
      "num_pages": 1,
      "current_page": 1
    }
  }
}
```

This endpoint retrieves a list of item receipt lines. Receipt lines of recurring orders are not included.

### HTTP Request

`https://example.procurify.com/api/v3/integrations/netsuite/item-receipt-lines/?status=<STATUS>`

### URL Parameters

#### status

Multiple statuses can be combined using comma-separation. Without it, item receipt lines of every status are returned. Any other value fails with 400 `INVALID_STATUS`.

Value       | Description
----------- | -----------
all         | Get all records, whatever their status (the default)
pending     | Get all records that need to be processed in NS (a combination of new/updated/deleted)
synced      | Get all synced records previously successfully synced
error       | Get all records that encountered an error during its most recent sync
ignore      | Get all records that are not meant to sync over to NS

#### id

Try it out! `?id=1234` will get you item receipt line with id=1234. **Can be comma separated**: `?id=1234,1235`

#### purchase_order

`?purchase_order=52` will get you the item receipt lines of the PO with id=52

### HTTP Response Status Code

200 OK

### Fun Facts

- New item receipt lines are guaranteed to have at least 1 item with quantity > 0
- `status=pending` only returns item receipt lines whose PO has a NetSuite external ID. If the PO's own sync is in error, only receipt lines that already have an external ID are returned.

## Get Vendors <code class='get'>GET</code>

> The above command returns a JSON structured like this:

```json
{
  "data": [
    {
      "id": 2,
      "name": "Staples",
      "active": true,
      "address_line_one": "1852 24th Ave",
      "address_line_two": "Unit 123",
      "postal_code": "72715",
      "city": "New York",
      "state_province": "NY",
      "country": "US",
      "email": "vendoremail@test.com",
      "alt_email": "vendoraltemail@test.com",
      "contact": "Joe Smith",
      "phone": "479-195-8789",
      "alt_phone": "479-696-4781",
      "fax": "479-222-5688",
      "comments": "Please call AR when placing PO to confirm receipt.",
      "url": "http://www.staples.com/",
      "payment_term": "Due on Receipt",
      "shipping_term": "FOB",
      "vendor_external_id": "VENDOR_EX_1",
      "external_id": "EX_VENDOR_2",
      "custom_fields": {}
    }
  ],
  "metadata": {
    "pagination": {
      "count": 1,
      "next": null,
      "previous": null,
      "page_size": 10,
      "num_pages": 1,
      "current_page": 1
    }
  }
}
```

This endpoint retrieves a list of vendors with specific status.

Only active vendors are returned. A vendor removed with Delete Vendor is left out, with or without `show_all`.

### HTTP Request

`https://example.procurify.com/api/v3/integrations/netsuite/vendors/?status=<STATUS>`

### URL Parameters

Parameter | Description                                                                                      | Example
--------- |--------------------------------------------------------------------------------------------------| ---------
STATUS | Object map status, case-insensitive: "pending", "synced", "error", "unsynced", "won't sync", "ignore", "manually synced", or "neutral". Omitted or unrecognized returns vendors with an object map in any status. Ignored when `show_all` is set. | `?status=pending`
name | name of the vendor                                                                               | `?name=BestBuy`
show_all     | Any value, including `false`, shows all active vendors, including vendors that were never synced. Might be useful for catalog item creation. | `?show_all=true`

### HTTP Response Status Code

200 OK

## Get Single Vendor Details <code class='get'>GET</code>

> The above command returns a JSON structured like this:

```json
{
  "data": {
    "id": 2,
    "name": "Staples",
    "active": true,
    "address_line_one": "1852 24th Ave",
    "address_line_two": "Unit 123",
    "postal_code": "72715",
    "city": "New York",
    "state_province": "NY",
    "country": "US",
    "email": "vendoremail@test.com",
    "alt_email": "vendoraltemail@test.com",
    "contact": "Joe Smith",
    "phone": "479-195-8789",
    "alt_phone": "479-696-4781",
    "fax": "479-222-5688",
    "comments": "Please call AR when placing PO to confirm receipt.",
    "url": "http://www.staples.com/",
    "payment_term": "Due on Receipt",
    "shipping_term": "FOB",
    "vendor_external_id": "VENDOR_EX_1",
    "external_id": "EX_VENDOR_2",
    "custom_fields": {}
  },
  "metadata": {}
}
```

This endpoint retrieves a specific vendor.

Only active vendors are returned. A vendor removed with Delete Vendor returns `404 Not Found` until it is reactivated.

### HTTP Request

`https://example.procurify.com/api/v3/integrations/netsuite/vendors/<VENDOR_ID>/`

### HTTP Response Status Code

200 OK

404 Not Found — vendor does not exist, is inactive, or vendor type is not syncable (`OTHER`, `EMPLOYEE`, `CC_PROVIDER`)

## Create Vendor <code class='post'>POST</code>

> The above command accepts a body:

```json
{
  "name": "Procurify",
  "address_line_one": "455 Granville St",
  "address_line_two": "300",
  "postal_code": "V6C 1T1",
  "city": "Vancouver",
  "state_province": "British Columbia",
  "country": "Canada",
  "email": "vendoremail@test.com",
  "alt_email": "vendoraltemail@test.com",
  "contact": "Joe Smith",
  "phone": "479-195-8789",
  "alt_phone": "479-696-4781",
  "fax": "479-222-5688",
  "comments": "Please call AR when placing PO to confirm receipt.",
  "url": "http://www.staples.com/",
  "payment_term": "Due on Receipt",
  "shipping_term": "FOB",
  "vendor_external_id": "VENDOR_EX_1",
  "external_id": "1234",
  "active": true
}
```

> The above command returns a JSON structured like this:

```json
{
  "data": {
    "id": 711,
    "name": "Procurify,",
    "active": true,
    "address_line_one": "455 Granville St",
    "address_line_two": "300",
    "postal_code": "V6C 1T1",
    "city": "Vancouver",
    "state_province": "British Columbia",
    "country": "Canada",
    "email": "vendoremail@test.com",
    "alt_email": "vendoraltemail@test.com",
    "contact": "Joe Smith",
    "phone": "479-195-8789",
    "alt_phone": "479-696-4781",
    "fax": "479-222-5688",
    "comments": "Please call AR when placing PO to confirm receipt.",
    "url": "http://www.staples.com/",
    "payment_term": "Due on Receipt",
    "shipping_term": "FOB",
    "vendor_external_id": "VENDOR_EX_1",
    "external_id": "1234",
    "custom_fields": {}
  },
  "metadata": {}
}
```

This endpoint creates a vendor, or updates the existing vendor already linked to the same NetSuite record.

The existing vendor is found by `external_id` first, through the integration's object map. If a vendor is renamed in NetSuite, the next sync updates the mapped Procurify vendor and renames it.

When no object map exists for the `external_id`, the vendor is matched by name. The oldest active vendor whose name is exactly the same, including case and trailing spaces, is updated and linked to the `external_id`. Other, employee and credit card provider vendors are never matched by name, and neither is a vendor already linked to a different `external_id`. Only when nothing matches is a new vendor created. After the first link, the object map is the only identity used.

When a vendor is updated, a field the request leaves out, or sends as `null` or `""`, keeps its stored value, so sync cannot clear a field. `email` and `alt_email` are different: the vendor's existing email addresses are always kept, after the ones in the request. Sending a new `email` makes the old one an alternate email instead of replacing it. `payment_term` and `shipping_term` keep their stored values only when left out.

A request whose `external_id` maps to a vendor type that is not synced (other, employee, or credit card provider) fails with `INVALID_VENDOR_TYPE`. When an existing vendor is matched, the rules for `active` and for `external_id` are the same as on Update Vendor. The response is `201 Created` in both cases.

`active` controls whether the sync reactivates the vendor. Sync never deactivates a vendor. Use Delete Vendor for that.

Request `active` | Existing vendor is active | Existing vendor is inactive | No existing vendor
---------------- | ------------------------- | --------------------------- | ------------------
omitted or `true` | stays active | reactivated | created active
`false` | stays active | stays inactive | not created, 400 `INACTIVE_VENDOR_NOT_CREATED`

A vendor matched by name is an existing vendor, and it is always active, so `active: false` with a name match links and updates it.

`active: false` never deactivates a vendor. To deactivate a vendor, call Delete Vendor.

A vendor removed with Delete Vendor keeps its object map. A later POST with the same `external_id` updates that vendor instead of creating a second one. It is reactivated unless the request sends `active: false`.

Omitting `active` is fully backward compatible; existing SuiteApp payloads need no change. Send `active` as a JSON boolean. Only the boolean `false` is read as false: the string `"false"`, `0` and similar values are treated as `true`. `null` returns a 400 validation error. `active` in the response reflects the Procurify record, not the request value.

The request body must be JSON. Other content types return `415 Unsupported Media Type`.

> When `active` is `false` and no existing vendor matches, the request fails with:

```json
{
  "errors": {
    "null": {
      "message": "Vendor is inactive in the accounting system and was not created.",
      "code": "INACTIVE_VENDOR_NOT_CREATED"
    }
  }
}
```

### HTTP Request

`https://example.procurify.com/api/v3/integrations/netsuite/vendors/`

### HTTP Response Status Code

201 Created

400 Bad Request — `active` is `false` and no existing vendor matches (`INACTIVE_VENDOR_NOT_CREATED`)

415 Unsupported Media Type — request body is not JSON

### Arguments

<code>name</code><span class="required-tag">required</span><br />
Vendor name.

<code>address_line_one</code><br />
Vendor address line one.

<code>address_line_two</code><br />
Vendor address line two.

<code>postal_code</code><br />
Vendor postal code.

<code>city</code><br />
Vendor city.

<code>state_province</code><br />
Vendor state or province.

<code>country</code><br />
Vendor country.

<code>email</code><br />
Vendor email.

<code>alt_email</code><br />
Vendor alternate email.

<code>contact</code><br />
Vendor contact.

<code>phone</code><br />
Vendor phone number.

<code>alt_phone</code><br />
Vendor alternate phone number.

<code>fax</code><br />
Vendor fax number.

<code>comments</code><br />
Vendor comments.

<code>url</code><br />
Vendor URL.

<code>payment_term</code><br />
Name of an active payment term. An unknown name returns a 400 validation error.

<code>shipping_term</code><br />
Name of an active shipping term. An unknown name returns a 400 validation error.

<code>vendor_external_id</code><br />
A field on the Procurify vendor record. It is not used to match vendors. Sending `null` or `""` keeps the stored value; only Delete Vendor clears it.

<code>external_id</code><span class="required-tag">required</span><br />
ID of the integration object. It is stored in the integration's object map, not on the vendor record. It matches the request to an existing vendor, with an exact name match as the fallback when it is not mapped yet. Delete Vendor keeps it.

<code>active</code><br />
Boolean. NetSuite's active/inactive flag for the record. Omitted or `true` creates the vendor active, or reactivates a matched inactive vendor. `false` leaves a matched vendor's active state unchanged and refuses to create a new vendor. Not nullable.

## Update Vendor <code class='put'>PUT</code>

> The above command accepts a body:

```json
{
  "name": "Procurify",
  "address_line_one": "455 Granville St",
  "address_line_two": "300",
  "postal_code": "V6C 1T1",
  "city": "Vancouver",
  "state_province": "British Columbia",
  "country": "Canada",
  "email": "vendoremail@test.com",
  "alt_email": "vendoraltemail@test.com",
  "contact": "Joe Smith",
  "phone": "479-195-8789",
  "alt_phone": "479-696-4781",
  "fax": "479-222-5688",
  "comments": "Please call AR when placing PO to confirm receipt.",
  "url": "http://www.staples.com/",
  "payment_term": "Due on Receipt",
  "shipping_term": "FOB",
  "vendor_external_id": "VENDOR_EX_1",
  "external_id": "1234",
  "active": true
}
```

> The above command returns a JSON structured like this:

```json
{
  "data": {
    "id": 711,
    "name": "Procurify,",
    "active": true,
    "address_line_one": "455 Granville St",
    "address_line_two": "300",
    "postal_code": "V6C 1T1",
    "city": "Vancouver",
    "state_province": "British Columbia",
    "country": "Canada",
    "email": "vendoremail@test.com",
    "alt_email": "vendoraltemail@test.com",
    "contact": "Joe Smith",
    "phone": "479-195-8789",
    "alt_phone": "479-696-4781",
    "fax": "479-222-5688",
    "comments": "Please call AR when placing PO to confirm receipt.",
    "url": "http://www.staples.com/",
    "payment_term": "Due on Receipt",
    "shipping_term": "FOB",
    "vendor_external_id": "VENDOR_EX_1",
    "external_id": "1234",
    "custom_fields": {}
  },
  "metadata": {}
}
```

This endpoint updates a specific vendor and links it to `external_id` in the integration's object map.

When a vendor is updated, a field the request leaves out, or sends as `null` or `""`, keeps its stored value, so sync cannot clear a field. `email` and `alt_email` are different: the vendor's existing email addresses are always kept, after the ones in the request. Sending a new `email` makes the old one an alternate email instead of replacing it. `payment_term` and `shipping_term` keep their stored values only when left out.

`active` controls whether the sync reactivates the vendor. Sync never deactivates a vendor. Use Delete Vendor for that.

Request `active` | Vendor is active | Vendor is inactive
---------------- | ---------------- | ------------------
omitted or `true` | stays active | reactivated
`false` | stays active | stays inactive

`active: false` never deactivates a vendor. To deactivate a vendor, call Delete Vendor.

There is no duplicate-name check. If `external_id` is already mapped to a different vendor, the request fails with 400 `EXTERNAL_ID_ALREADY_MAPPED` and nothing is written. Sending a new `external_id` for a vendor moves that vendor's own mapping to the new id.

Omitting `active` is fully backward compatible; existing SuiteApp payloads need no change. Send `active` as a JSON boolean. Only the boolean `false` is read as false: the string `"false"`, `0` and similar values are treated as `true`. `null` returns a 400 validation error. `active` in the response reflects the Procurify record, not the request value.

The request body must be JSON. Other content types return `415 Unsupported Media Type`.

> When `external_id` is already mapped to a different vendor, the request fails with:

```json
{
  "errors": {
    "null": {
      "message": "This external id is already mapped to a different vendor.",
      "code": "EXTERNAL_ID_ALREADY_MAPPED"
    }
  }
}
```

### HTTP Request

`https://example.procurify.com/api/v3/integrations/netsuite/vendors/<VENDOR_ID>/`

### URL Parameters

Parameter | Description
--------- | -----------
VENDOR_ID | ID of the vendor being updated

### HTTP Response Status Code

200 OK

400 Bad Request — `external_id` is already mapped to a different vendor (`EXTERNAL_ID_ALREADY_MAPPED`)

415 Unsupported Media Type — request body is not JSON

### Arguments

<code>name</code><span class="required-tag">required</span><br />
Vendor name.

<code>address_line_one</code><br />
Vendor address line one.

<code>address_line_two</code><br />
Vendor address line two.

<code>postal_code</code><br />
Vendor postal code.

<code>city</code><br />
Vendor city.

<code>state_province</code><br />
Vendor state or province.

<code>country</code><br />
Vendor country.

<code>email</code><br />
Vendor email.

<code>alt_email</code><br />
Vendor alternate email.

<code>contact</code><br />
Vendor contact.

<code>phone</code><br />
Vendor phone number.

<code>alt_phone</code><br />
Vendor alternate phone number.

<code>fax</code><br />
Vendor fax number.

<code>comments</code><br />
Vendor comments.

<code>url</code><br />
Vendor URL.

<code>payment_term</code><br />
Name of an active payment term. An unknown name returns a 400 validation error.

<code>shipping_term</code><br />
Name of an active shipping term. An unknown name returns a 400 validation error.

<code>vendor_external_id</code><br />
A field on the Procurify vendor record. It is not used to match vendors. Sending `null` or `""` keeps the stored value; only Delete Vendor clears it.

<code>external_id</code><span class="required-tag">required</span><br />
ID of the integration object. It is stored in the integration's object map, not on the vendor record. The vendor to update comes from the URL; `external_id` is only written to the object map. Delete Vendor keeps it.

<code>active</code><br />
Boolean. NetSuite's active/inactive flag for the record. Omitted or `true` reactivates an inactive vendor. `false` leaves the vendor's active state unchanged; it never deactivates. Not nullable.

## Delete Vendor <code class='delete'>DELETE</code>

This endpoint soft deletes a specific vendor. It deactivates the vendor and clears `vendor_external_id`, the field on the vendor record. The vendor record is not removed. Its object map also stays, so `external_id` still links the vendor to the NetSuite record.

To bring the vendor back, call Reactivate Vendor, or call Create Vendor with the same `external_id`. Until then, Get Vendors leaves the vendor out and Get Single Vendor Details returns `404 Not Found`.

Checkout and Amazon punchout vendors cannot be deleted. The request fails with 400 `INVALID_VENDOR_DEACTIVATION`, unless the account has punchout vendor deletion enabled.

This endpoint takes no request body. If one is sent, it must be JSON. Other content types return `415 Unsupported Media Type`, and the vendor is not changed.

### HTTP Request

`https://example.procurify.com/api/v3/integrations/netsuite/vendors/<VENDOR_ID>/`

### URL Parameters

Parameter | Description
--------- | -----------
VENDOR_ID | ID of the vendor being soft deleted

### HTTP Response Status Code

204 No Content

400 Bad Request — vendor is a checkout or Amazon punchout vendor (`INVALID_VENDOR_DEACTIVATION`)

404 Not Found — vendor does not exist, or vendor type is not syncable (`OTHER`, `EMPLOYEE`, `CC_PROVIDER`)

415 Unsupported Media Type — request body is not JSON

## Reactivate Vendor <code class='patch'>PATCH</code>

> The above command accepts a body:

```json
{
  "external_id": "1234"
}
```

> The above command returns a JSON structured like this:

```json
{
  "data": {
    "id": 711,
    "name": "Procurify,",
    "active": true,
    "address_line_one": "455 Granville St",
    "address_line_two": "300",
    "postal_code": "V6C 1T1",
    "city": "Vancouver",
    "state_province": "British Columbia",
    "country": "Canada",
    "email": "vendoremail@test.com",
    "alt_email": "vendoraltemail@test.com",
    "contact": "Joe Smith",
    "phone": "479-195-8789",
    "alt_phone": "479-696-4781",
    "fax": "479-222-5688",
    "comments": "Please call AR when placing PO to confirm receipt.",
    "url": "http://www.staples.com/",
    "payment_term": "Due on Receipt",
    "shipping_term": "FOB",
    "vendor_external_id": null,
    "external_id": "1234",
    "custom_fields": {}
  },
  "metadata": {}
}
```

> When the vendor is already active, the request fails with:

```json
{
  "errors": {
    "null": {
      "message": "Vendor is already active.",
      "code": "VENDOR_ALREADY_ACTIVE"
    }
  }
}
```

This endpoint reactivates a vendor that was previously deactivated. Delete Vendor clears `vendor_external_id`, the field on the vendor record, but keeps the object map. Reactivate sets the object map to the `external_id` in the request. It does not set `vendor_external_id` again, so after a Delete Vendor the response returns `null` for that field.

There is no duplicate-name check on reactivation. A vendor can be reactivated even if another active vendor shares the same name.

The request body must be JSON. Other content types return `415 Unsupported Media Type`.

### HTTP Request

`https://example.procurify.com/api/v3/integrations/netsuite/vendors/<VENDOR_ID>/reactivate/`

### URL Parameters

Parameter | Description
--------- | -----------
VENDOR_ID | ID of the vendor being reactivated

### HTTP Response Status Code

200 OK

400 Bad Request — vendor is already active (`VENDOR_ALREADY_ACTIVE`)

404 Not Found — vendor does not exist, or vendor type is not syncable (`OTHER`, `EMPLOYEE`, `CC_PROVIDER`)

415 Unsupported Media Type — request body is not JSON

### Arguments

<code>external_id</code><span class="required-tag">required</span><br />
ID of the integration object. Reactivate sets the vendor's object map to this value.

## Get Logs <code class='get'>GET</code>

### HTTP Request

`https://example.procurify.com/api/v3/integrations/netsuite/logs/`

> The above command returns a JSON structured like this:

```json
{
  "data": [
    {
      "id": 1,
      "sync_status": "Info",
      "is_incoming": false,
      "object_details": {
        "id": 10,
        "content_type": 60,
        "external_id": "external-account-code-10",
        "uuid": "",
        "identifier": "account_code_1 - description",
        "message": "Sync Complete"
      },
      "created_at": "2019-12-10T17:47:00.373867-08:00",
      "request": {},
      "response": {}
    },
    {
      "id": 2,
      "sync_status": "Info",
      "is_incoming": false,
      "object_details": {
        "id": 20,
        "content_type": 21,
        "external_id": "external-vendor-20",
        "uuid": "",
        "identifier": "Vendor 1",
        "message": "Sync Complete"
      },
      "created_at": "2019-12-10T17:47:00.373867-08:00"
    },
    {
      "id": 3,
      "sync_status": "Error",
      "is_incoming": false,
      "object_details": {
        "id": 30,
        "content_type": 23,
        "external_id": "external-po-30",
        "uuid": "6bfcf0610fd211eaa1e506ca8f09037c",
        "identifier": "PF30",
        "message": "You have entered an Invalid Field Value 2 for the following field: location."
      },
      "created_at": "2019-12-10T17:47:00.373867-08:00"
    },
    {
      "id": 4,
      "sync_status": "Error",
      "is_incoming": false,
      "object_details": {
        "id": 40,
        "content_type": 280,
        "external_id": "external-reciept-item-40",
        "uuid": "6bfcf0610fd211eaa1e506ca8f09037c",
        "identifier": "PF30",
        "message": "You can not initialize itemreceipt: invalid reference 42111."
      },
      "created_at": "2019-12-10T17:47:00.373867-08:00"
    }
  ],
  "metadata": {
    "pagination": {
      "count": 5,
      "next": null,
      "previous": null,
      "page_size": 10,
      "num_pages": 1,
      "current_page": 1
    }
  }
}
```

Each log also has `request` and `response`, the JSON payloads saved with the log. They are only shown on the first entry above.

### URL Parameters

Parameter   | Values
------------| -----------
status      | `success`, `error`
object_type | `purchaseorder`, `receiptline`, `accountcode`, `vendor`, `bill`, `payment`
object_id   | ID of the Procurify object
search      | text to find in the log message

### HTTP Response Status Code

200 OK

## Batch Upsert Object Maps  <code class='post'>POST</code>

### HTTP Request

`https://example.procurify.com/api/v3/integrations/netsuite/object-maps/batch/`

> The above command accepts a body:

```json
[
  {
    "object_id": 151,
    "content_type": 23,
    "status": 1,
    "external_id": "1234",
    "message": "Error Message"
  },
  {
    "object_id": 121,
    "content_type": 23,
    "status": 1,
    "external_id": "1244",
    "message": "Error Message"
  }
]
```

> The above command returns a JSON structured like this:

```json
{
  "data": [
    {
      "id": 1,
      "object_id": 151,
      "status": 1,
      "content_type": 23,
      "external_id": "1234",
      "datetime_last_synced": "2020-01-02T10:15:00-08:00"
    },
    {
      "id": 2,
      "object_id": 121,
      "status": 1,
      "content_type": 23,
      "external_id": "1244",
      "datetime_last_synced": "2020-01-02T10:15:00-08:00"
    }
  ],
  "metadata": {}
}
```

This endpoint batch upserts multiple object maps. Each entry follows the same rules as Upsert Object Map, including the default `status`.

Batch upsert only supports purchase orders, item receipt lines, vendors, accounts and payment terms. Any other content type fails with 400 `Unsupported type for object map creation.` Every `object_id` must exist.

### HTTP Response Status Code

201 CREATED

400 Bad Request — an entry's content type is not supported

### Arguments

<code>object_id</code><span class="required-tag">required</span><br />
ID of the Procurify object.

<code>content_type</code><span class="required-tag">required</span><br />
ID of Procurify content_type.

<code>status</code><br />
Object map status ID. See the status table under Upsert Object Map.

<code>external_id</code><br />
ID of the integration object.

<code>message</code><br />
Optional message to save to integration logs.

## Create Catalog Item <code class='post'>POST</code>

This endpoint creates a catalog item, or updates the existing catalog item already linked to the same NetSuite record.

A new catalog item is assigned to every active department. `department_ids` is not accepted. A request that sends it fails with 400 `CATALOG_ITEM_DEPARTMENT_IDS_NOT_ACCEPTED`, and nothing is created or changed.

The existing catalog item is found by `external_id` through the integration's object map, including an item removed with Delete Catalog Item. A matched item is updated instead of creating a duplicate, with the same rules as Update Catalog Item, including the rules for fields the request leaves out. The response is `201 Created` in both cases.

`active` controls whether the sync reactivates the catalog item. Sync never deactivates a catalog item. Use Delete Catalog Item for that.

Request `active` | Existing item is active | Existing item is inactive | No existing item
---------------- | ----------------------- | ------------------------- | ----------------
omitted or `true` | stays active | reactivated | created active
`false` | stays active | stays inactive | not created, 400 `INACTIVE_CATALOG_ITEM_NOT_CREATED`

`active: false` never deactivates a catalog item. To deactivate a catalog item, call Delete Catalog Item.

A reactivated catalog item comes back in the departments it had, but not in its bundles: Delete Catalog Item removes it from its bundles, and reactivation does not add it back. Its custom field values are kept unless the request sends `custom_fields`. A reactivated item with no departments is not visible to requesters while catalog permissions are on.

To keep a catalog item in step with NetSuite, call Delete Catalog Item when the item goes inactive in NetSuite. When it is active again, send the normal Create Catalog Item or Update Catalog Item request with `active` omitted or `true`.

Omitting `active` is fully backward compatible; existing SuiteApp payloads need no change. Sending `null`, or a value that cannot be read as a boolean, returns a 400 validation error. `active` in the response reflects the Procurify record, not the request value.

The request body can be JSON or form-encoded. The strings `"true"` and `"false"` are read as booleans, so `"false"` behaves the same as `false`.

> When `active` is `false` and no existing catalog item matches, the request fails with:

```json
{
  "errors": {
    "null": {
      "message": "Catalog item is inactive in the accounting system and was not created.",
      "code": "INACTIVE_CATALOG_ITEM_NOT_CREATED"
    }
  }
}
```

### HTTP Request

`https://example.procurify.com/api/v3/integrations/netsuite/catalog-items/`

> The above command accepts a body:

```json
{
  "name": "Some new item",
  "unit_type": "each",
  "vendor": 6,
  "account_code": 1,
  "internal_sku": "1234",
  "description": "This is an item",
  "product_url": "https://www.procurify.com",
  "currency": 1,
  "cost": "1.00000000",
  "external_id": "1234",
  "active": true,
  "custom_fields": [
    {
      "custom_field_name": "An existing custom field",
      "custom_field_value": "An appropriate value"
    }
  ]
}
```

> The above command returns a JSON structured like this:

```json
{
  "data": {
    "id": 31,
    "name": "Some new item",
    "unit_type": "each",
    "vendor": 6,
    "account_code": 1,
    "internal_sku": "1234",
    "active": true,
    "description": "This is an item",
    "product_url": "https://www.procurify.com",
    "currency": 1,
    "cost": "1.00000000",
    "external_id": "1234",
    "custom_fields": {
      "An existing custom field": "An appropriate value"
    }
  },
  "metadata": {}
}
```

### HTTP Response Status Code

201 CREATED

400 Bad Request — `active` is `false` and no existing catalog item matches (`INACTIVE_CATALOG_ITEM_NOT_CREATED`), or the request sends `department_ids` (`CATALOG_ITEM_DEPARTMENT_IDS_NOT_ACCEPTED`)

### Arguments

<code>name</code><span class="required-tag">required</span><br />
Name of your item.

<code>unit_type</code><br />
Unit name of your item. (Ex: each, liters, feet, etc)

<code>vendor</code><br />
The primary key to a Procurify vendor. You will need to query the respective API for this.

<code>account_code</code><br />
The primary key to a Procurify account code (a.k.a. GL code). You will need to query the respective API for this.

<code>internal_sku</code><br />
A string representing some sort of serial/sku number.

<code>currency</code><br />
The primary key to a Procurify currency. You will need to query the respective API for this.

<code>description</code><br />
A more lengthy blob of text to describe your catalog item

<code>product_url</code><br />
An external link to your item (Ex: if it's from Amazon, maybe a link to the Amazon's page. Or if it's on wikipedia,
maybe a wiki link.)

<code>cost</code><br />
Amount for your item.

<code>custom_fields[]</code><br />
A list of custom fields to be assigned to your catalog item. Each custom field object in the list must have an appropriate value and matching name to one of your active custom fields in Procurify, and the list must include every required catalog item custom field.

<code>external_id</code><span class="required-tag">required</span><br />
ID of the integration object. It is stored in the integration's object map, and it is the only value used to match the request to an existing catalog item. Delete Catalog Item keeps it.

<code>active</code><br />
Boolean. NetSuite's active/inactive flag for the record. Omitted or `true` creates the catalog item active, or reactivates a matched inactive item. `false` leaves a matched item's active state unchanged and refuses to create a new item. Not nullable.

## Update Catalog Item <code class='put'>PUT</code>

This endpoint updates a specific catalog item. `CATALOG_ITEM_ID` is the Procurify catalog item ID, not the NetSuite `external_id`.

Fields the request leaves out are handled like this:

* `name` is required.
* `cost`, `description`, `unit_type`, `internal_sku`, `product_url`, `vendor` and `account_code` are set from the body. One that the body leaves out is cleared to its default: `0` for `cost`, an empty string for the text fields, and no vendor or account code. The SuiteApp leaves a field out when it is empty in NetSuite, so clearing it keeps the item in step.
* `currency` keeps the stored value when the body leaves it out.
* Custom field values are only replaced when the body sends `custom_fields`. The list replaces all of the item's custom field values, and an explicit `[]` clears them. The list must include every required catalog item custom field, so `[]` is only accepted when none are required. When `custom_fields` is left out, the stored values are kept.
* Department tags are never changed by an update. `department_ids` is ignored.

An inactive catalog item can be updated, and `active` controls whether the sync reactivates it. Sync never deactivates a catalog item. Use Delete Catalog Item for that.

Request `active` | Item is active | Item is inactive
---------------- | -------------- | ----------------
omitted or `true` | stays active | reactivated
`false` | stays active | stays inactive

`active: false` never deactivates a catalog item. To deactivate a catalog item, call Delete Catalog Item.

A reactivated catalog item comes back in the departments it had, but not in its bundles. Its custom field values are kept unless the request sends `custom_fields`.

Omitting `active` is fully backward compatible; existing SuiteApp payloads need no change. Sending `null`, or a value that cannot be read as a boolean, returns a 400 validation error. `active` in the response reflects the Procurify record, not the request value.

The request body can be JSON or form-encoded. The strings `"true"` and `"false"` are read as booleans, so `"false"` behaves the same as `false`.

### HTTP Request

`https://example.procurify.com/api/v3/integrations/netsuite/catalog-items/<CATALOG_ITEM_ID>/`

### URL Parameters

Parameter | Description
--------- | -----------
CATALOG_ITEM_ID | ID of the catalog item being updated

> The above command accepts a body:

```json
{
  "name": "Some new item",
  "unit_type": "each",
  "vendor": 6,
  "account_code": 1,
  "internal_sku": "1234",
  "description": "This is an item",
  "product_url": "https://www.procurify.com",
  "currency": 1,
  "cost": "1.00000000",
  "external_id": "1234",
  "active": true,
  "custom_fields": [
    {
      "custom_field_name": "An existing custom field",
      "custom_field_value": "An appropriate value"
    }
  ]
}
```

> The above command returns a JSON structured like this:

```json
{
  "data": {
    "id": 31,
    "name": "Some new item",
    "unit_type": "each",
    "vendor": 6,
    "account_code": 1,
    "internal_sku": "1234",
    "active": true,
    "description": "This is an item",
    "product_url": "https://www.procurify.com",
    "currency": 1,
    "cost": "1.00000000",
    "external_id": "1234",
    "custom_fields": {
      "An existing custom field": "An appropriate value"
    }
  },
  "metadata": {}
}
```

### HTTP Response Status Code

200 OK

400 Bad Request — `external_id` differs from the catalog item's object map (`Resource has different external ID from original.`), or the catalog item has no object map (`Resource not previously synced.`)

404 Not Found — catalog item does not exist

### Arguments

<code>name</code><span class="required-tag">required</span><br />
Name of your item.

<code>unit_type</code><br />
Unit name of your item. (Ex: each, liters, feet, etc)

<code>vendor</code><br />
The primary key to a Procurify vendor. You will need to query the respective API for this.

<code>account_code</code><br />
The primary key to a Procurify account code (a.k.a. GL code). You will need to query the respective API for this.

<code>internal_sku</code><br />
A string representing some sort of serial/sku number.

<code>currency</code><br />
The primary key to a Procurify currency. You will need to query the respective API for this.

<code>description</code><br />
A more lengthy blob of text to describe your catalog item

<code>product_url</code><br />
An external link to your item (Ex: if it's from Amazon, maybe a link to the Amazon's page. Or if it's on wikipedia,
maybe a wiki link.)

<code>cost</code><br />
Amount for your item.

<code>custom_fields[]</code><br />
A list of custom fields to be assigned to your catalog item. Each custom field object in the list must have an appropriate value and matching name to one of your active custom fields in Procurify, and the list must include every required catalog item custom field. When sent, it replaces all of the item's custom field values; `[]` clears them when no catalog item custom field is required. When left out, the stored values are kept.

<code>external_id</code><span class="required-tag">required</span><br />
ID of the integration object. It must match the catalog item's object map.

<code>active</code><br />
Boolean. NetSuite's active/inactive flag for the record. Omitted or `true` reactivates an inactive catalog item. `false` leaves the item's active state unchanged; it never deactivates. Not nullable.

## Delete Catalog Item  <code class='delete'>DELETE</code>

This endpoint deactivates a specific catalog item, the same as a delete in the catalog UI. The item is removed from its bundles. Its department tags, custom field values and object map are kept, so `external_id` still links the item to the NetSuite record.

Create Catalog Item or Update Catalog Item with the same `external_id` brings the item back. See those endpoints for what a reactivated item keeps.

### HTTP Request

`https://example.procurify.com/api/v3/integrations/netsuite/catalog-items/<CATALOG_ITEM_ID>/`

### URL Parameters

Parameter | Description
--------- | -----------
CATALOG_ITEM_ID | ID of the catalog item being deactivated

### HTTP Response Status Code

204 No Content

400 Bad Request — the catalog item has no object map (`Resource not previously synced.`)

404 Not Found — catalog item does not exist or is already inactive

## Get Currencies  <code class='get'>GET</code>

### HTTP Request

`https://example.procurify.com/api/v3/integrations/netsuite/currencies/`

### HTTP Response Status Code

200 OK

### URL Parameters

Parameter    | Description                                                                                                                                     | Example
------------ |-------------------------------------------------------------------------------------------------------------------------------------------------| ----
show_all     | Due to currencies not synced between NS + PFY, please be sure to always pass this in | `?show_all=true`
name         | name filter, useful to reduce the query speed + reduce response size                                                                            | `?name=USD`

### HTTP Response

> The above command returns a JSON structured like this:

```json
{
  "data": [
    {
      "id": 1,
      "name": "CAD",
      "rate": "0.769231",
      "active": true,
      "description": "",
      "base": false,
      "external_id": null,
      "custom_fields": {
      }
    },
    {
      "id": 3,
      "name": "USD",
      "rate": "1.000000",
      "active": true,
      "description": "",
      "base": true,
      "external_id": null,
      "custom_fields": {
      }
    },
    {
      "id": 4,
      "name": "EUR",
      "rate": "0.769231",
      "active": true,
      "description": "",
      "base": false,
      "external_id": null,
      "custom_fields": {
      }
    },
    {
      "id": 86,
      "name": "KRW",
      "rate": "1.538462",
      "active": true,
      "description": "",
      "base": false,
      "external_id": null,
      "custom_fields": {
      }
    }
  ],
  "metadata": {
    "pagination": {
      "count": 4,
      "next": null,
      "previous": null,
      "page_size": 10,
      "num_pages": 1,
      "current_page": 1
    }
  }
}
```

## Get Departments  <code class='get'>GET</code>

### HTTP Request

`https://example.procurify.com/api/v3/integrations/netsuite/departments/`

### HTTP Response Status Code

200 OK

### URL Parameters

Parameter    | Description                                                                           | Example
------------ |---------------------------------------------------------------------------------------| ----
show_all     | Due to departments not synced between NS + PFY, please be sure to always pass this in | `?show_all=true`
department_name | name filter, useful to reduce the query speed + reduce response size                  | `?department_name=Marketing`
location_name | Due to the fact department names can be repeated across multiple locations, one must also filter by location name to ensure you assign the department ID | `?location_name=Vancouver`


### HTTP Response

> The above command returns a JSON structured like this:

```json
{
    "data": [
        {
            "id": 1,
            "name": "Accounting",
            "branch_id": 1,
            "active": true,
            "external_id": null,
            "custom_fields": {}
        },
        {
            "id": 2,
            "name": "Public Affairs",
            "branch_id": 1,
            "active": true,
            "external_id": null,
            "custom_fields": {}
        },
        {
            "id": 3,
            "name": "Computer Science",
            "branch_id": 1,
            "active": true,
            "external_id": null,
            "custom_fields": {}
        },
        {
            "id": 4,
            "name": "Mission Operations",
            "branch_id": 1,
            "active": true,
            "external_id": null,
            "custom_fields": {}
        },
        {
            "id": 5,
            "name": "Aerospace",
            "branch_id": 1,
            "active": true,
            "external_id": null,
            "custom_fields": {}
        },
        {
            "id": 6,
            "name": "Contracting",
            "branch_id": 1,
            "active": true,
            "external_id": null,
            "custom_fields": {}
        },
        {
            "id": 7,
            "name": "Shipping/Receiving",
            "branch_id": 2,
            "active": true,
            "external_id": null,
            "custom_fields": {}
        },
        {
            "id": 8,
            "name": "Spare Parts",
            "branch_id": 2,
            "active": true,
            "external_id": null,
            "custom_fields": {}
        },
        {
            "id": 9,
            "name": "Maintenance",
            "branch_id": 2,
            "active": true,
            "external_id": null,
            "custom_fields": {}
        },
        {
            "id": 10,
            "name": "Supplies",
            "branch_id": 3,
            "active": true,
            "external_id": null,
            "custom_fields": {}
        }
    ],
    "metadata": {
        "pagination": {
            "count": 30,
            "next": "http://antonio.dev.procurify.xyz/api/v3/integrations/netsuite/departments/?page=2&show_all=True",
            "previous": null,
            "page_size": 10,
            "num_pages": 3,
            "current_page": 1
        }
    }
}
```
