import copy,json,tempfile,pathlib,unittest,subprocess
import export_metadata
class MetadataTests(unittest.TestCase):
 def setUp(self):self.content=json.loads(pathlib.Path('packages/core/assets/content.json').read_text())
 def test_local_image_uploads_survive_without_active_content(self):
  image='data:image/png;base64,iVBORw0KGgo='
  self.assertEqual(export_metadata.safe_image(image),image)
  self.assertEqual(export_metadata.safe_image('data:image/svg+xml,<svg onload="alert(1)">'),'')
  self.assertEqual(export_metadata.safe_image('javascript:alert(1)'),'')
 def test_drafts_are_not_exported(self):
  c=copy.deepcopy(self.content);p=next(iter(c['collections']['projects'].values()));p['status']='draft';p['title']='PRIVATE SENTINEL';p['slug']='private-test'
  with tempfile.TemporaryDirectory() as directory:
   path=pathlib.Path(directory);(path/'content.json').write_text(json.dumps(c))
   subprocess.run(['python3','tools/export_metadata.py','--content',str(path/'content.json'),'--web-root',str(path/'web')],check=True,capture_output=True)
   text=''.join(p.read_text() for p in (path/'web').rglob('*.html'))+(path/'web/sitemap.xml').read_text()
   self.assertNotIn('PRIVATE SENTINEL',text);self.assertNotIn('private-test',text)
 def test_user_content_is_escaped(self):
  self.content['profile']['name']='</script><script>alert(1)</script>'
  self.assertNotIn('<script>alert(1)</script>',export_metadata.render(self.content))
 def test_unpublishing_removes_old_static_page(self):
  with tempfile.TemporaryDirectory() as directory:
   path=pathlib.Path(directory);source=path/'content.json';web=path/'web'
   source.write_text(json.dumps(self.content))
   command=['python3','tools/export_metadata.py','--content',str(source),'--web-root',str(web)]
   subprocess.run(command,check=True,capture_output=True)
   p=next(pr for pr in self.content['collections']['projects'].values() if pr['slug']=='fix')
   self.assertTrue((web/'projects/fix/index.html').exists())
   p['status']='draft';source.write_text(json.dumps(self.content))
   subprocess.run(command,check=True,capture_output=True)
   self.assertFalse((web/'projects/fix').exists())
   self.assertNotIn('/projects/fix</loc>',(web/'sitemap.xml').read_text())
 def test_case_study_metadata_and_verified_links(self):
  p=next(pr for pr in self.content['collections']['projects'].values() if pr['slug']=='fix')
  text=export_metadata.render(self.content,'/projects/fix',p)
  self.assertIn('https://portfolio-ce1ae.web.app/projects/fix',text);self.assertIn(p['googlePlayUrl'].replace('&','&amp;'),text)
  self.assertNotIn('My role &amp; contribution',text)
if __name__=='__main__':unittest.main()
