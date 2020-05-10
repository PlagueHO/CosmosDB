using System;

namespace CosmosDB {
    public enum Environment {
        AzureCloud,
        AzureUSGovernment
    }


    public class ContextToken
    {
        public System.String Resource;
        public System.DateTime TimeStamp;
        public System.DateTime Expires;
        public System.Security.SecureString Token;
    }

    public class BackoffPolicy
    {
        public System.Int32 MaxRetries;
        public System.String Method;
        public System.Int32 Delay;
    }

    public class Context
    {
        public System.String Account;
        public System.String Database;
        public System.Security.SecureString Key;
        public System.String KeyType;
        public System.String BaseUri;
        public CosmosDB.ContextToken[] Token;
        public CosmosDB.BackoffPolicy BackoffPolicy;
        public CosmosDB.Environment Environment;
    }

    namespace IndexingPolicy {
        namespace Path {
            public class Index {
                public System.String dataType;
                public System.String kind;
            }

            public class IndexRange : CosmosDB.IndexingPolicy.Path.Index {
                public readonly System.Int32 precision = -1;
            }

            public class IndexHash : CosmosDB.IndexingPolicy.Path.Index {
                public readonly System.Int32 precision = -1;
            }

            public class IndexSpatial : CosmosDB.IndexingPolicy.Path.Index {
            }

            public class IncludedPath
            {
                public System.String path;
            }

            public class IncludedPathIndex : IncludedPath
            {
                public CosmosDB.IndexingPolicy.Path.Index[] indexes;
            }

            public class ExcludedPath
            {
                public System.String path;
            }
        }


        namespace CompositeIndex {
            public class Element
            {
                public System.String path;
                public System.String order;
            }
        }

        public class Policy
        {
            public System.Boolean automatic;
            public System.String indexingMode;
            public CosmosDB.IndexingPolicy.Path.IncludedPath[] includedPaths;
            public CosmosDB.IndexingPolicy.Path.ExcludedPath[] excludedPaths;
            public CosmosDB.IndexingPolicy.CompositeIndex.Element[][] compositeIndexes;
        }
    }

    namespace UniqueKeyPolicy {
        public class UniqueKey {
            public System.String[] paths;
        }

        public class Policy
        {
            public CosmosDB.UniqueKeyPolicy.UniqueKey[] uniqueKeys;
        }
    }
}
