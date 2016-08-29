using System;
using System.Collections.Generic;
using Needletail.DataAccess;
using Needletail.DataAccess.Engines;
using Needletail.DataAccess.Entities;
using __NAME__.Models;

namespace __NAME__.DataAccess.Repositories
{
    //Add Bussiness logic here
    public class EmailMessagesRepository : IDisposable, IDataSource<EmailMessages, Guid> 
    {
        DBTableDataSourceBase<EmailMessages, Guid> dataSource;

        string ConnectionString { get; set; }

        string tableName;
        private string TableName 
        {
            get 
            {
                if (string.IsNullOrWhiteSpace(tableName))
                { 
                }
                return tableName;
            }
            set 
            {
                tableName = value;
            }
        }

        public EmailMessagesRepository()
        {
            this.TableName = typeof(EmailMessages).Name;
            this.ConnectionString = "Default";
            InitializeDataSource();
        }

        public EmailMessagesRepository(string connectionString)
        {
            this.TableName = typeof(EmailMessages).Name;
            this.ConnectionString = connectionString;
            InitializeDataSource();
        }

        public EmailMessagesRepository(string connectionString,string tableName)
        {
            this.ConnectionString = connectionString;
            this.TableName = tableName;
            InitializeDataSource();
        }

        private void InitializeDataSource()
        {
            dataSource = new DBTableDataSourceBase<EmailMessages, Guid>(this.ConnectionString, this.TableName);
        }

        public bool Delete(object where, FilterType filterType)
        {
            return this.dataSource.Delete(@where: where, filterType: filterType);
        }

        public bool Delete(object where)
        {
            return this.dataSource.Delete(@where: where);
        }

        public bool DeleteEntity(EmailMessages item)
        {
            return this.dataSource.DeleteEntity(item: item);
        }

        public IEnumerable<EmailMessages> GetAll()
        {
            return this.dataSource.GetAll();
        }

        public IEnumerable<EmailMessages> GetAll(object orderBy)
        {
            return this.dataSource.GetAll(orderBy: orderBy);
        }

        public IEnumerable<EmailMessages> GetMany(string select, string where, string orderBy)
        {
            return this.dataSource.GetMany(@select: select, @where: where, orderBy: orderBy);
        }

        public IEnumerable<EmailMessages> GetMany(object where)
        {
            return this.dataSource.GetMany(@where: where);
        }

        public IEnumerable<EmailMessages> GetMany(object where, object orderBy)
        {
            return this.dataSource.GetMany(@where: where, orderBy: orderBy);
        }

        public IEnumerable<EmailMessages> GetMany(object where, FilterType filterType, object orderBy, int? topN)
        {
            return this.dataSource.GetMany(@where: where, filterType: filterType, orderBy: orderBy, topN: topN);
        }

        public IEnumerable<EmailMessages> GetMany(object where, object orderBy, FilterType filterType, int page, int pageSize)
        {
            return this.dataSource.GetMany(@where: where, orderBy: orderBy, filterType: filterType, page: page, pageSize: pageSize);
        }

        public IEnumerable<EmailMessages> GetMany(string where, string orderBy, Dictionary<string, object> args, int page, int pageSize)
        {
            return this.dataSource.GetMany(@where: where, orderBy: orderBy, args: args, page: page, pageSize: pageSize);
        }

        public IEnumerable<EmailMessages> GetMany(string where, string orderBy, Dictionary<string, object> args, int? topN)
        {
            return this.dataSource.GetMany(@where: where, orderBy: orderBy, args: args, topN: topN);
        }

        public IEnumerable<DynamicEntity> Join(string selectColumns, string joinQuery, string whereQuery, string orderBy, Dictionary<string, object> args)
        {
            return this.dataSource.Join(selectColumns: selectColumns, joinQuery: joinQuery, whereQuery: whereQuery, orderBy: orderBy, args: args);
        }

        public IEnumerable<T> JoinGetTyped<T>(string selectColumns, string joinQuery, string whereQuery, string orderBy, Dictionary<string, object> args)
        {
            return this.dataSource.JoinGetTyped<T>(selectColumns: selectColumns, joinQuery: joinQuery, whereQuery: whereQuery, orderBy: orderBy, args: args);
        }

        public EmailMessages GetSingle(object where)
        {
            return this.dataSource.GetSingle(@where: where);
        }

        public EmailMessages GetSingle(object where, FilterType filterType)
        {
            return this.dataSource.GetSingle(@where: where, filterType: filterType);
        }

        public EmailMessages GetSingle(string where, Dictionary<string, object> args)
        {
            return this.dataSource.GetSingle(@where: where, args: args);
        }

        public Guid Insert(EmailMessages newItem)
        {
            return this.dataSource.Insert(newItem: newItem);
        }

        public bool Update(object item)
        {
            return this.dataSource.Update(item: item);
        }

        public bool UpdateWithWhere(object values, object where, FilterType filterType)
        {
            return this.dataSource.UpdateWithWhere(values: values, @where: where, filterType: filterType);
        }

        public bool UpdateWithWhere(object values, object where)
        {
            return this.dataSource.UpdateWithWhere(values: values, @where: where);
        }

        public void ExecuteNonQuery(string query, Dictionary<string, object> args)
        {
            this.dataSource.ExecuteNonQuery(query: query, args: args);
        }

        public T ExecuteScalar<T>(string query, Dictionary<string, object> args)
        {
            return this.dataSource.ExecuteScalar<T>(query: query, args: args);
        }

        public void Dispose()
        {
            this.dataSource.Dispose();
        }

        public void ExecuteStoredProcedure(string name, object parameters)
        {
            this.dataSource.ExecuteStoredProcedure(name, parameters);
        }

        public IEnumerable<T> ExecuteStoredProcedureReturnRows<T>(string name, object parameters)
        {
            return this.ExecuteStoredProcedureReturnRows<T>(name, parameters);
        }


        public IEnumerable<DynamicEntity> ExecuteStoredProcedureReturnDynaimcRows(string name, object parameters)
        {
            return this.ExecuteStoredProcedureReturnDynaimcRows(name, parameters);
        }
    }
}
