'''Implement the Distutils "build_help" command.'''

from glob import glob
import os.path
import distutils.cmd

class build_help(distutils.cmd.Command):
    description = 'install docbook XML based documentation'
    user_options= [('help-dir', None, 'help directory in the source tree')]
	
    def initialize_options(self):
        self.help_dir = None

    def finalize_options(self):
        if self.help_dir is None:
            self.help_dir = 'help'

    def get_data_files(self):
        data_files = []
        name = self.distribution.metadata.name
        omf_pattern = os.path.join(self.help_dir, '*', '*.omf')

        for path in glob(os.path.join(self.help_dir, '*')):
            lang = os.path.basename(path)
            path_xml = os.path.join('share/gnome/help', name, lang)
            path_figures = os.path.join('share/gnome/help', name, lang, 'figures')
            
            docbook_files = glob('%s/*.xml' % path)
            mallard_files = glob('%s/*.page' % path)
            data_files.append((path_xml, docbook_files + mallard_files))
            data_files.append((path_figures, glob('%s/figures/*.png' % path)))
        
        omf_files = glob(omf_pattern)
        if omf_files:
            data_files.append((os.path.join('share', 'omf', name), omf_files))
        
        return data_files
    
    def run(self):
        self.announce('Setting up help files...')
        
        data_files = self.distribution.data_files
        data_files.extend(self.get_data_files())
