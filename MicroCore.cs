﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using SAPbouiCOM;
using SAPbobsCOM;
using System.IO;
using AddOne.Framework.Service;
using Castle.Core.Logging;
using AddOne.Framework.Model.SAP.Assembly;

namespace AddOne
{
    public class MicroCore
    {
        private SAPbobsCOM.Company company;
        private DatabaseConfiguration dbConf;
        private AssemblyLoader assemblyLoader;

        public ILogger Logger { get; set; }

        public MicroCore(DatabaseConfiguration dbConf, SAPbobsCOM.Company company, AssemblyLoader assemblyLoader)
        {
            this.company = company;
            this.dbConf = dbConf;
            this.assemblyLoader = assemblyLoader;
        }

        public string PrepareCore()
        {
            try
            {
                dbConf.PrepareDatabase();

                if (InsideInception())
                    return null;

                string appFolder = CheckAppFolder();

                UpdateCore(appFolder);
                UpdateAddins(appFolder);

                return appFolder;
            }
            catch (Exception e)
            {
                Logger.Fatal("Erro inicializando Core.", e);
                Environment.Exit(10);
                return null;
            }
        }

        private string CheckAppFolder()
        {
            string appFolder = Environment.GetFolderPath(Environment.SpecialFolder.ApplicationData) + "\\AddOne";
            CreateIfNotExists(appFolder);
            appFolder = Path.Combine(appFolder, company.Server + "-" + company.CompanyDB);
            CreateIfNotExists(appFolder);
            return appFolder;
        }

        private void CreateIfNotExists(string appFolder)
        {
            if (System.IO.Directory.Exists(appFolder) == false)
            {
                System.IO.Directory.CreateDirectory(appFolder);
            }
        }

        private void UpdateAddins(string appFolder)
        {
            assemblyLoader.UpdateAssemblies(AssemblySource.AddIn, appFolder);
        }

        private void UpdateCore(string appFolder)
        {
            assemblyLoader.UpdateAssemblies(AssemblySource.Core, appFolder);
        }

        private bool InsideInception()
        {
            return AppDomain.CurrentDomain.FriendlyName == "AddOne.Inception";
        }
    }
}