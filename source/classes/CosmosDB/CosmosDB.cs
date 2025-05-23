﻿using System;
using System.Net;

namespace CosmosDB
{
    public enum Environment
    {
        AzureChinaCloud,
        AzureCloud,
        AzureUSGovernment
    }

    public class ContextToken
    {
        public System.String Resource { get; set; }
        public System.DateTime TimeStamp { get; set; }
        public System.DateTime Expires { get; set; }
        public System.Security.SecureString Token { get; set; }
    }

    public class BackoffPolicy
    {
        public System.Int32 MaxRetries { get; set; }
        public System.String Method { get; set; }
        public System.Int32 Delay { get; set; }
    }

    public class Context
    {
        public System.String Account { get; set; }
        public System.String Database { get; set; }
        public System.Security.SecureString Key { get; set; }
        public System.String KeyType { get; set; }
        public System.String BaseUri { get; set; }
        public CosmosDB.ContextToken[] Token { get; set; }
        public System.Security.SecureString EntraIdToken { get; set; }
        public CosmosDB.BackoffPolicy BackoffPolicy { get; set; }
        public CosmosDB.Environment Environment { get; set; } = Environment.AzureCloud;
    }

    namespace IndexingPolicy
    {
        namespace Path
        {
            public class Index
            {
                public System.String dataType { get; set; }
                public System.String kind { get; set; }
            }

            public class IndexRange : CosmosDB.IndexingPolicy.Path.Index
            {
                public readonly System.Int32 precision = -1;
            }

            public class IndexHash : CosmosDB.IndexingPolicy.Path.Index
            {
                public readonly System.Int32 precision = -1;
            }

            public class IndexSpatial : CosmosDB.IndexingPolicy.Path.Index
            {
            }

            public class IncludedPath
            {
                public System.String path { get; set; }
            }

            public class IncludedPathIndex : IncludedPath
            {
                public CosmosDB.IndexingPolicy.Path.Index[] indexes { get; set; }
            }

            public class ExcludedPath
            {
                public System.String path { get; set; }
            }
        }


        namespace CompositeIndex
        {
            public class Element
            {
                public System.String path { get; set; }
                public System.String order { get; set; }
            }
        }

        public class Policy
        {
            public System.Boolean automatic { get; set; }
            public System.String indexingMode { get; set; }
            public CosmosDB.IndexingPolicy.Path.IncludedPath[] includedPaths { get; set; }
            public CosmosDB.IndexingPolicy.Path.ExcludedPath[] excludedPaths { get; set; }
            public CosmosDB.IndexingPolicy.CompositeIndex.Element[][] compositeIndexes { get; set; }
        }
    }

    namespace UniqueKeyPolicy
    {
        public class UniqueKey
        {
            public System.String[] paths { get; set; }
        }

        public class Policy
        {
            public CosmosDB.UniqueKeyPolicy.UniqueKey[] uniqueKeys { get; set; }
        }
    }

    // ResponseException is used to handle exceptions that occur during the invocation of CosmosDB operations.
    // Todo: Change to be based on Microsoft.PowerShell.Commands.HttpResponseException in 7.0.0.
    // This will prevent this module from working in Windows PowerShell 5.1 because this class doesn't exist.
    // Proposal is to drop support for Windows PowerShell 5.1 in 7.0.0.
    public class ResponseException : System.Exception
    {
        public ResponseException(System.String message) : base(message) { }
        public ResponseException(System.String message, System.Net.HttpStatusCode statusCode) : base(message)
        {
            this.StatusCode = statusCode;
        }
        public System.Net.HttpStatusCode? StatusCode { get; set; } = null;
        public System.String Response { get; set; } = "";
        public override System.String ToString()
        {
            return this.Message;
        }
    }
}
